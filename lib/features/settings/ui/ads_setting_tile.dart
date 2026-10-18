// lib/features/settings/ui/ads_setting_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twenty48/features/consent/consent_link_style.dart';
import 'package:twenty48/features/consent/consent_service.dart';
import 'package:twenty48/features/consent/consent_texts.dart';
import 'package:twenty48/core/services/ad_service.dart';
import 'package:twenty48/features/settings/providers/theme_provider.dart';

class AdsSettingTile extends StatefulWidget {
  final ConsentService? consentService;

  const AdsSettingTile({super.key, this.consentService});

  @override
  State<AdsSettingTile> createState() => _AdsSettingTileState();
}

class _AdsSettingTileState extends State<AdsSettingTile> {
  late final ConsentService _consentService;
  bool _adsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _consentService = widget.consentService ?? ConsentService();
    _loadConsentState();
    AdService.instance.adsEnabledListenable.addListener(_onAdsEnabledChanged);
  }

  @override
  void dispose() {
    AdService.instance.adsEnabledListenable.removeListener(
      _onAdsEnabledChanged,
    );
    super.dispose();
  }

  void _onAdsEnabledChanged() {
    if (!mounted) return;
    setState(() {
      _adsEnabled = AdService.instance.adsEnabled;
    });
  }

  Future<void> _loadConsentState() async {
    final status = await _consentService.load();
    if (!mounted) return;
    setState(() {
      _adsEnabled = (status == ConsentStatus.agreed);
      _isLoading = false;
    });
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    try {
      final uri = Uri.parse(kPrivacyUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kConsentLinkFailureMessage)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(kConsentLinkFailureMessage)),
        );
      }
    }
  }

  void _showConsentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = context.watch<ThemeProvider>().currentTheme;
        final primaryText = theme.textColor;
        final bodyColor = primaryText.withValues(alpha: 0.8);
        final linkColor = primaryText == Colors.white
            ? kConsentLinkDarkBgColor
            : kConsentLinkLightBgColor;

        return AlertDialog(
          backgroundColor: theme.backgroundColor,
          title: Text(
            kConsentTitle,
            style: TextStyle(color: primaryText, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  kConsentBody,
                  style: TextStyle(color: bodyColor, height: 1.5),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => _launchPrivacyPolicy(context),
                    child: Text(
                      kConsentPrivacyLinkLabel,
                      style: TextStyle(
                        color: linkColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: bodyColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _consentService.save(true);
                await AdService.instance.enableAds();
                if (mounted) {
                  setState(() {
                    _adsEnabled = true;
                  });
                }
              },
              child: const Text('I agree'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return ListTile(
      leading: Icon(Icons.ad_units, color: theme.textColor),
      title: Text('Ads', style: TextStyle(color: theme.textColor)),
      subtitle: Text(
        'Show ads and optional ad rewards',
        style: TextStyle(color: theme.textColor.withValues(alpha: 0.7)),
      ),
      trailing: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: _adsEnabled,
              activeThumbColor: const Color(0xFFE65100),
              activeTrackColor: const Color(0xFFE65100).withValues(alpha: 0.5),
              onChanged: (value) async {
                if (value) {
                  _showConsentDialog(context);
                } else {
                  await _consentService.save(false);
                  AdService.instance.disableAds();
                  if (mounted) {
                    setState(() {
                      _adsEnabled = false;
                    });
                  }
                }
              },
            ),
    );
  }
}
