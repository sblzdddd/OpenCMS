import 'package:flutter/material.dart';
import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/pages/actions/web_cms.dart';
import '../../ui/shared/dialog/confirm_dialog.dart';
import '../../ui/theme/pages/theme_settings_page.dart';
import '../../ui/skin/pages/skin_settings_page.dart';
import '../../services/theme/theme_services.dart';
import 'package:provider/provider.dart';
import '../../ui/shared/widgets/custom_app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../ui/shared/widgets/custom_scaffold.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/widgets/app_card.dart';
import 'package:opencms/pages/settings/privacy_policy.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _clearUserData() {
    showClearDataDialog(context);
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Widget? page, {
    Function? onTap,
  }) {
    // Theme Settings Section
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
        if (page != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            Icon(
              Symbols.chevron_right_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      skinKey: 'settings',
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(tr('settings.title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsTitle(tr('settings.theme')),
              Consumer<ThemeNotifier>(
                builder: (context, themeNotifier, child) {
                  return Column(
                    children: [
                      // Dark Mode Toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  themeNotifier.isDarkMode
                                      ? Symbols.dark_mode_rounded
                                      : Symbols.light_mode_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tr('settings.darkMode'),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            Switch(
                              value: themeNotifier.isDarkMode,
                              onChanged: (value) {
                                themeNotifier.toggleTheme();
                                // Window effect will be automatically reapplied in toggleTheme()
                              },
                              activeThumbColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 2),

                      // Language Selection
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Symbols.language_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  tr('settings.language'),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            DropdownButton<Locale>(
                              value: context.locale,
                              underline: Container(),
                              icon: Icon(
                                Symbols.arrow_drop_down_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              items: context.supportedLocales.map((
                                Locale locale,
                              ) {
                                String languageName;
                                switch (locale.toString()) {
                                  case 'en_US':
                                    languageName = 'English';
                                    break;
                                  case 'zh_CN':
                                    languageName = '简体中文';
                                    break;
                                  default:
                                    languageName = locale.toString();
                                }
                                return DropdownMenuItem<Locale>(
                                  value: locale,
                                  child: Text(
                                    languageName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                );
                              }).toList(),
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  context.setLocale(newLocale);
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // const Divider(height: 2);

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     vertical: 6.0,
                      //     horizontal: 8.0,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Icon(
                      //             Symbols.access_time_rounded,
                      //             color: Theme.of(context).colorScheme.primary,
                      //           ),
                      //           const SizedBox(width: 12),
                      //           Text(
                      //             'Use 24H Time Format',
                      //             style: Theme.of(context).textTheme.bodyLarge,
                      //           ),
                      //         ],
                      //       ),
                      //       Switch(
                      //         value:
                      //             false, // TODO: Implement 24H time format toggle
                      //         onChanged: (value) {
                      //           // TODO: Implement 24H time format toggle
                      //         },
                      //         activeColor: Theme.of(
                      //           context,
                      //         ).colorScheme.primary,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                tr('settings.themeSettings'),
                Symbols.palette_rounded,
                const ThemeSettingsPage(),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                tr('settings.skins'),
                Symbols.brush_rounded,
                const SkinSettingsPage(),
              ),
              const Divider(height: 2),

              // _buildSettingsTitle('Notifications'),
              // _buildSettingsItem(
              //   'Notification Settings',
              //   Symbols.notifications_rounded,
              //   const ThemeSettingsPage(),
              // ),
              // const Divider(height: 2),
              _buildSettingsTitle(tr('settings.account')),
              _buildSettingsItem(
                tr('settings.changePassword'),
                Symbols.password_rounded,
                const WebCmsPage(
                  initialUrl: '${API.cmsReferer}/auth/change_password',
                  windowTitle: 'Change Password',
                ),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                tr('settings.logout'),
                Symbols.logout_rounded,
                null,
                onTap: () => showLogoutDialog(context),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                tr('settings.clearUserData'),
                Symbols.delete_forever_rounded,
                null,
                onTap: () => _clearUserData(),
              ),
              const Divider(height: 2),
              _buildSettingsTitle(tr('settings.about')),
              const AppCard(),
              const Divider(height: 2),
              _buildSettingsItem(
                tr('settings.privacyLegal'),
                Symbols.privacy_tip_rounded,
                const PrivacyPolicyPage(),
              ),
              const Divider(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
