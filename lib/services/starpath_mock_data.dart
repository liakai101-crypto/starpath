import 'package:flutter/material.dart';

import '../features/base/models/signal_record.dart';
import '../features/capsule/models/capsule_memory.dart';
import '../features/orbit/models/friend_planet.dart';

class StarPathMockData {
  const StarPathMockData._();

  static List<FriendPlanet> planets() {
    return [
      FriendPlanet(
        name: 'Unknown EX-001',
        energy: 0.30,
        unlocked: false,
        color: Colors.purple,
        radius: 190,
        offset: 0,
        formation: 'Research',
        relationshipLabel: 'Slow-burn research link',
        lastContactLabel: 'Quiet for 4 days',
        memoryCount: 1,
        nextAction: 'Send a low-pressure check-in',
        mutualGravityAccepted: false,
        position: const Offset(120, 180),
        velocity: const Offset(0.45, 0.32),
      ),
      FriendPlanet(
        name: 'EX-002',
        energy: 0.68,
        unlocked: false,
        color: Colors.cyanAccent,
        radius: 140,
        offset: 2,
        formation: 'Sport',
        relationshipLabel: 'Activity-driven orbit',
        lastContactLabel: 'Active last night',
        memoryCount: 2,
        nextAction: 'Share a short update',
        position: const Offset(620, 250),
        velocity: const Offset(-0.62, 0.38),
      ),
      FriendPlanet(
        name: 'Cpt. Alex',
        energy: 0.85,
        unlocked: true,
        color: Colors.greenAccent,
        radius: 90,
        offset: 4,
        formation: 'Research',
        relationshipLabel: 'Trusted collaborator',
        lastContactLabel: 'Replied recently',
        memoryCount: 3,
        nextAction: 'Open the shared capsule',
        position: const Offset(420, 120),
        velocity: const Offset(0.36, -0.48),
      ),
    ];
  }

  static List<SignalRecord> signals() {
    return const [
      SignalRecord(
        friendName: 'EX-002',
        title: 'Late-night orbit ping',
        summary: 'Recent replies cluster at night. Keep the next message light.',
        energyDelta: 0.15,
        color: Colors.cyanAccent,
      ),
      SignalRecord(
        friendName: 'Cpt. Alex',
        title: 'Stable gravity window',
        summary: 'This orbit is stable. A short catch-up would strengthen it.',
        energyDelta: 0.08,
        color: Colors.greenAccent,
      ),
      SignalRecord(
        friendName: 'Unknown EX-001',
        title: 'Weak signal detected',
        summary: 'Long silence detected. Reconnect with a low-pressure prompt.',
        energyDelta: 0.05,
        color: Colors.purple,
      ),
    ];
  }

  static List<CapsuleMemory> memories() {
    return const [
      CapsuleMemory(
        friendName: 'Cpt. Alex',
        title: 'Meteor Cafe',
        caption: 'The afternoon you both forgot to check the time.',
        color: Colors.greenAccent,
        unlocked: true,
      ),
      CapsuleMemory(
        friendName: 'Navigator Emma',
        title: 'First Coordinate',
        caption: 'The first shared trace appears after Emma is unlocked.',
        color: Colors.cyanAccent,
        unlocked: false,
      ),
      CapsuleMemory(
        friendName: 'Unknown EX-001',
        title: 'Locked Capsule',
        caption: 'Raise the energy level to open this memory.',
        color: Colors.purple,
        unlocked: false,
      ),
    ];
  }
}
