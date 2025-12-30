import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/API/storage/token_storage.dart';
import 'package:opencms/features/auth/services/auth_service.dart';
import 'package:opencms/features/navigations/views/app_navigation_controller.dart';
import 'package:opencms/features/shared/constants/api_endpoints.dart';
import 'package:opencms/features/web_cms/views/pages/web_cms.dart';
import '../shared/views/dialog/confirm_dialog.dart';
import 'theme_settings_page.dart';
import '../theme/views/pages/skin_settings_page.dart';
import '../theme/services/theme_services.dart';
import 'package:provider/provider.dart';
import '../shared/views/widgets/custom_app_bar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../shared/views/widgets/custom_scaffold.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';
import 'package:opencms/features/shared/views/widgets/app_card.dart';
import 'package:opencms/features/settings/privacy_policy.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  void _clearUserData(BuildContext context) {
    showConfirmationDialog(
      context,
      'Clear Data',
      'Are you sure you want to clear all user data?\nThis action cannot be undone and will delete ALL your data and restart the application.',
      (dialogContext) async {
        Navigator.of(dialogContext).pop();
        await di<AuthService>().logout();
        if (context.mounted) {
          // Ensure global navigation state is cleared and remove all routes
          AppNavigationController.reset();

          // Ensure window close prevention is maintained after logout
          // if (defaultTargetPlatform == TargetPlatform.windows) {
          //   await windowManager.setPreventClose(true);
          // }
          if (!context.mounted) {
            debugPrint('ClearDataDialog: Context is not mounted');
            return;
          }
          // Navigator.of(
          //   context,
          // ).pushNamedAndRemoveUntil('/login', (route) => false);
          Phoenix.rebirth(context);
        }
      },
    );
  }

  void _clearTokens() {
    showConfirmationDialog(
      context,
      'Clear Tokens',
      'Are you sure you want to clear all stored tokens and cookies?\n(Restart required)',
      (dialogContext) async {
        Navigator.of(dialogContext).pop();
        await di<TokenStorage>().clearAll();
        
        Phoenix.rebirth(context);
      },
    );
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
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsTitle('Theme'),
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
                                  'Dark Mode',
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
                    ],
                  );
                },
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Theme Settings',
                Symbols.palette_rounded,
                const ThemeSettingsPage(),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Skins',
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
              _buildSettingsTitle('Account'),
              _buildSettingsItem(
                'Change Password',
                Symbols.password_rounded,
                const WebCmsPage(
                  initialUrl: '${API.cmsReferer}/auth/change_password',
                  windowTitle: 'Change Password',
                ),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Logout',
                Symbols.logout_rounded,
                null,
                onTap: () => showLogoutDialog(context),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Clear Tokens',
                Symbols.delete_sweep_rounded,
                null,
                onTap: () => _clearTokens(),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Clear All Data',
                Symbols.delete_forever_rounded,
                null,
                onTap: () => _clearUserData(context),
              ),
              const Divider(height: 2),
              _buildSettingsTitle('About'),
              const AppCard(),
              const Divider(height: 2),
              _buildSettingsItem(
                'Privacy & Legal',
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
