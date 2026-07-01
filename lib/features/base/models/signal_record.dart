import 'package:flutter/material.dart';

class SignalRecord {
  const SignalRecord({
    required this.friendName,
    required this.title,
    required this.summary,
    required this.energyDelta,
    required this.color,
  });

  final String friendName;
  final String title;
  final String summary;
  final double energyDelta;
  final Color color;
}
