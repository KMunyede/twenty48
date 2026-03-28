// lib/features/game/ui/widgets/tile_widget.dart

import 'package:flutter/material.dart';
import '../../models/tile.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;

  const TileWidget({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getTileColor(tile.value),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          '${tile.value}',
          style: TextStyle(
            fontSize: tile.value < 100 ? 32 : (tile.value < 1000 ? 24 : 18),
            fontWeight: FontWeight.bold,
            color: tile.value <= 4 ? const Color(0xFF776E65) : Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFEEE4DA);
      case 4: return const Color(0xFFEDE0C8);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return const Color(0xFFEDC22E);
      default: return const Color(0xFF3C3A32);
    }
  }
}
