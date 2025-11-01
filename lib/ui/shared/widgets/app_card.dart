import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/app_info.dart';
import '../scaled_ink_well.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key});

  static const String _githubPage = 'https://github.com/sblzdddd/OpenCMS/';

  Future<void> _openReleases() async {
    final Uri uri = Uri.parse(_githubPage);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaledInkWell(
      borderRadius: BorderRadius.circular(12),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      background: (inkWell) => Material(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        child: inkWell,
      ),
      onTap: _openReleases,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/icon/Full/OCMS_ICON_256.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'OpenCMS',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: AppInfoUtil.getVersionText(),
                        builder: (context, snapshot) {
                          final String versionText = snapshot.data ?? '';
                          return Text(
                            versionText.isNotEmpty ? versionText : '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                      const Spacer(),
                      Icon(
                        Symbols.open_in_new_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'An open source, highly freedom CMS APP.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String>(
                    future: AppInfoUtil.getDeviceText(),
                    builder: (context, snapshot) {
                      final String deviceText =
                          'running on ${snapshot.data ?? 'Unknown Device'}';
                      return Text(
                        deviceText.isNotEmpty ? deviceText : 'Unknown Device',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
