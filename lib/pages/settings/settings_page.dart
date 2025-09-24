import 'package:flutter/material.dart';
import 'package:opencms/data/constants/api_endpoints.dart';
import 'package:opencms/pages/actions/web_cms.dart';
import '../../ui/shared/dialog/confirm_dialog.dart';
import 'theme_settings_page.dart';
import '../../services/theme/theme_services.dart';
import 'package:provider/provider.dart';

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
              Icons.chevron_right,
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
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
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
                              },
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      // const Divider(height: 2),

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
                      //             Icons.access_time,
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
                'Theme Settings',
                Icons.palette,
                const ThemeSettingsPage(),
              ),
              const Divider(height: 2),
              // _buildSettingsTitle('Notifications'),
              // _buildSettingsItem(
              //   'Notification Settings',
              //   Icons.notifications,
              //   const ThemeSettingsPage(),
              // ),
              // const Divider(height: 2),

              _buildSettingsTitle('Account'),
              _buildSettingsItem(
                'Change Password',
                Icons.password,
                const WebCmsPage(initialUrl: '${ApiConstants.cmsReferer}/auth/change_password', windowTitle: 'Change Password'),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Logout',
                Icons.logout,
                null,
                onTap: () => showLogoutDialog(context),
              ),
              const Divider(height: 2),
              _buildSettingsItem(
                'Clear User Data',
                Icons.delete_forever,
                null,
                onTap: () => _clearUserData(),
              ),
              const Divider(height: 2),
              _buildSettingsTitle("About This App"),
              _buildSettingsItem('App Info', Icons.info, null),
              const Divider(height: 2),
              _buildSettingsItem('Privacy Policy', Icons.privacy_tip, null),
              const Divider(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}
