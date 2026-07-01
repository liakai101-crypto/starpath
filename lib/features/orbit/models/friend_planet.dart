import 'package:flutter/material.dart';

class FriendPlanet {
  String name;
  double energy;
  bool unlocked;
  Color color;
  double radius;
  double offset;
  String formation;
  String relationshipLabel;
  String lastContactLabel;
  int memoryCount;
  String nextAction;
  bool mutualGravityAccepted;
  bool blocked;
  Offset position;
  Offset velocity;
  bool movingAway;

  FriendPlanet({
    required this.name,
    required this.energy,
    required this.unlocked,
    required this.color,
    required this.radius,
    required this.offset,
    required this.formation,
    this.relationshipLabel = 'Connection',
    this.lastContactLabel = '',
    this.memoryCount = 0,
    this.nextAction = '',
    this.mutualGravityAccepted = true,
    this.blocked = false,
    this.position = Offset.zero,
    this.velocity = const Offset(0.7, 0.4),
    this.movingAway = false,
  });
}
