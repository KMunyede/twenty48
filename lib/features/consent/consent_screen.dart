// lib/features/consent/consent_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/ump_consent_service.dart';
import '../../core/theme/contrast_text.dart';
import 'consent_link_style.dart';
import 'consent_service.dart';
import 'consent_texts.dart';

class ConsentScreen extends StatefulWidget {
  final ConsentService consentService;
  final UmpConsentService umpConsentService;
  final ValueChanged<bool> onDecision;

  ConsentScreen({
    super.key,
    ConsentService? consentService,
    UmpConsentService? umpConsentService,
    required this.onDecision,
  })  : consentService = consentService ?? ConsentService(),
        umpConsentService = umpConsentService ?? const UmpConsentService();

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _isSaving = false;

  void _enableAdsSafely() {
    try {
      unawaited(AdService.instance.enableAds().catchError((e) {
        debugPrint('ConsentScreen enableAds error: $e');
      }));
    } catch (e) {
      debugPrint('ConsentScreen enableAds exception: $e');
    }
  }

  Future<void> _handleDecision(bool agreed) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    await widget.consentService.save(agreed);

    if (agreed) {
      final canRequest = await widget.umpConsentService.gatherConsent();
      if (canRequest) {
        _enableAdsSafely();
      }
    }

    if (mounted) {
      widget.onDecision(agreed);
    }
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
          const SnackBar(
            content: Text(kConsentLinkFailureMessage),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(kConsentLinkFailureMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final bgColor = theme.scaffoldBackgroundColor;
    final primaryText = readableTextOn(bgColor);
    final titleColor = primaryText;
    final bodyColor = primaryText == Colors.white ? Colors.white70 : Colors.black54;
    final linkColor = primaryText == Colors.white ? kConsentLinkDarkBgColor : kConsentLinkLightBgColor;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    label: kConsentTitle,
                    child: Text(
                      kConsentTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                      ) ??
                          TextStyle(
                            color: titleColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Semantics(
                    label: kConsentBody,
                    child: Text(
                      kConsentBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: bodyColor,
                        height: 1.5,
                      ) ??
                          TextStyle(
                            color: bodyColor,
                            fontSize: 16,
                            height: 1.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Semantics(
                      button: true,
                      label: kConsentPrivacyLinkLabel,
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
                  ),
                  const SizedBox(height: 32.0),
                  Semantics(
                    button: true,
                    label: kConsentAgreeButtonLabel,
                    enabled: !_isSaving,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _handleDecision(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0x801B5E20),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        kConsentAgreeButtonLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Semantics(
                    button: true,
                    label: kConsentDeclineButtonLabel,
                    enabled: !_isSaving,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () => _handleDecision(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0x80E65100),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        kConsentDeclineButtonLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
