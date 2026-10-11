// lib/features/consent/consent_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/ad_service.dart';
import 'consent_service.dart';
import 'consent_texts.dart';

class ConsentScreen extends StatefulWidget {
  final ConsentService consentService;
  final ValueChanged<bool> onDecision;

  ConsentScreen({
    super.key,
    ConsentService? consentService,
    required this.onDecision,
  }) : consentService = consentService ?? ConsentService();

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
      _enableAdsSafely();
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                        fontWeight: FontWeight.bold,
                      ) ??
                          const TextStyle(
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
                        height: 1.5,
                      ) ??
                          const TextStyle(
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
                        child: const Text(
                          kConsentPrivacyLinkLabel,
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
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
