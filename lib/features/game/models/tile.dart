// lib/features/game/models/tile.dart

import 'package:uuid/uuid.dart';

class Tile {
  final String id;
  final int x;
  final int y;
  final int value;
  final bool isMerged;
  final bool isNew;

  Tile({
    String? id,
    required this.x,
    required this.y,
    required this.value,
    this.isMerged = false,
    this.isNew = false,
  }) : id = id ?? const Uuid().v4();

  Tile copyWith({
    int? x,
    int? y,
    int? value,
    bool? isMerged,
    bool? isNew,
  }) {
    return Tile(
      id: id,
      x: x ?? this.x,
      y: y ?? this.y,
      value: value ?? this.value,
      isMerged: isMerged ?? this.isMerged,
      isNew: isNew ?? this.isNew,
    );
  }
}
