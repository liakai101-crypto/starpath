import 'package:flutter/material.dart';

class CapsuleMemory {
  const CapsuleMemory({
    required this.friendName,
    required this.title,
    required this.caption,
    required this.color,
    required this.unlocked,
  });

  final String friendName;
  final String title;
  final String caption;
  final Color color;
  final bool unlocked;
}
