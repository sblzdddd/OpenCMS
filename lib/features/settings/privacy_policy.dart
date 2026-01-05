import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/shared/views/widgets/custom_app_bar.dart';
import 'package:opencms/features/shared/views/widgets/custom_scaffold.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      skinKey: 'privacy_policy',
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Privacy & Legal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Privacy Policy'),
            const SizedBox(height: 4),
            Text(
              'This application is an independent, community-maintained project and is not affiliated with any public organizations or schools. Your use''rname (Use''r I''d) and De''vice I''d might be collected for automated services (to ensure such service is not abused), based on your agreement to this additional service. Apart from that, We do not collect, store, analyze, or transmit any personal data or usage analytics to our servers or any third parties. Your credentials, if stored, are kept securely and locally on your device. By choosing to use this application, you acknowledge and accept that, because the source code is publicly available, there is an inherent risk of data exposure that cannot be entirely eliminated despite our best efforts to use secure storage mechanisms.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Legal Notice'),
            const SizedBox(height: 4),
            Text(
              'This application is provided on an “as is” basis, without warranties of any kind, whether express or implied, including but not limited to merchantability or fitness for a particular purpose. The authors and contributors shall not be liable for any claims, damages, or other liabilities, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software. \n\nNetwork requests may be made to your institution\'s official services when you sign in or fetch data; such requests are initiated by you and are limited to the necessary interactions with those services.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('License'),
            const SizedBox(height: 4),
            Text(
              'This application is licensed under the GNU General Public License (GPL) version 3. You are permitted to use, modify, and redistribute this software under the terms of the GNU GPL, including making the corresponding source code available to recipients. For the precise conditions and obligations, please refer to https://www.gnu.org/licenses/gpl-3.0.txt.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
