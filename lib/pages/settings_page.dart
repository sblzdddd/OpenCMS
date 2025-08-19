import 'package:flutter/material.dart';
import '../services/shared/storage_client.dart';
import '../ui/shared/logout_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _clearUserData() {
    StorageClient.instance.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => showLogoutDialog(context),
              child: const Text('Log Out'),
            ),
            ElevatedButton(
              onPressed: _clearUserData,
              child: const Text('Clear User Data'),
            ),
          ],
        ),
      ),
    );
  }
}
