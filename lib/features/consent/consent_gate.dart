// lib/features/consent/consent_gate.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import 'consent_screen.dart';
import 'consent_service.dart';

class ConsentGate extends StatefulWidget {
  final Widget child;
  final ConsentService? consentService;

  const ConsentGate({
    super.key,
    required this.child,
    this.consentService,
  });

  @override
  State<ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<ConsentGate> {
  late final ConsentService _consentService;
  ConsentStatus? _status;

  @override
  void initState() {
    super.initState();
    _consentService = widget.consentService ?? ConsentService();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final status = await _consentService.load();
    if (!mounted) return;

    if (status == ConsentStatus.agreed) {
      _enableAdsSafely();
    }

    setState(() {
      _status = status;
    });
  }

  void _enableAdsSafely() {
    try {
      unawaited(AdService.instance.enableAds().catchError((e) {
        debugPrint('ConsentGate enableAds error: $e');
      }));
    } catch (e) {
      debugPrint('ConsentGate enableAds exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
    }

    switch (_status!) {
      case ConsentStatus.agreed:
      case ConsentStatus.declined:
        return widget.child;
      case ConsentStatus.needsPrompt:
        return ConsentScreen(
          consentService: _consentService,
          onDecision: (agreed) {
            if (!mounted) return;
            setState(() {
              _status = agreed ? ConsentStatus.agreed : ConsentStatus.declined;
            });
          },
        );
    }
  }
}
