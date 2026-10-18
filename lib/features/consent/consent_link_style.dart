// lib/features/consent/consent_link_style.dart

import 'package:flutter/material.dart';

/// Link colors for Privacy Policy link meeting WCAG 2.1 AA 4.5:1 contrast requirement.
/// [kConsentLinkDarkBgColor] (0xFFA5D6A7) against dark background (0xFF2E3338) contrast ratio ~7.73:1.
/// [kConsentLinkLightBgColor] (0xFF1B5E20) against light background (0xFFC3C7E0) contrast ratio ~4.79:1.
const Color kConsentLinkDarkBgColor = Color(0xFFA5D6A7);
const Color kConsentLinkLightBgColor = Color(0xFF1B5E20);
