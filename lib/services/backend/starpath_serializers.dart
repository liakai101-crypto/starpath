import 'package:flutter/material.dart';

import '../../features/base/models/signal_record.dart';
import '../../features/capsule/models/capsule_memory.dart';
import '../../features/orbit/models/friend_planet.dart';
import 'backend_field.dart';

class StarPathSerializers {
  const StarPathSerializers._();

  static Map<String, Object> friendPlanetToMap(FriendPlanet planet) {
    return {
      BackendField.name: planet.name,
      BackendField.energy: planet.energy,
      BackendField.unlocked: planet.unlocked,
      BackendField.color: _colorToInt(planet.color),
      BackendField.radius: planet.radius,
      BackendField.offset: planet.offset,
      BackendField.formation: planet.formation,
      BackendField.mutualGravityAccepted: planet.mutualGravityAccepted,
      BackendField.blocked: planet.blocked,
    };
  }

  static FriendPlanet friendPlanetFromMap(Map<String, Object?> map) {
    return FriendPlanet(
      name: _string(map, BackendField.name),
      energy: _double(map, BackendField.energy),
      unlocked: _bool(map, BackendField.unlocked),
      color: _colorFromInt(_int(map, BackendField.color)),
      radius: _double(map, BackendField.radius),
      offset: _double(map, BackendField.offset),
      formation: _string(map, BackendField.formation),
      mutualGravityAccepted: _bool(map, BackendField.mutualGravityAccepted),
      blocked: _bool(map, BackendField.blocked),
    );
  }

  static Map<String, Object> signalRecordToMap(SignalRecord signal) {
    return {
      BackendField.friendName: signal.friendName,
      BackendField.title: signal.title,
      BackendField.summary: signal.summary,
      BackendField.energyDelta: signal.energyDelta,
      BackendField.color: _colorToInt(signal.color),
    };
  }

  static SignalRecord signalRecordFromMap(Map<String, Object?> map) {
    return SignalRecord(
      friendName: _string(map, BackendField.friendName),
      title: _string(map, BackendField.title),
      summary: _string(map, BackendField.summary),
      energyDelta: _double(map, BackendField.energyDelta),
      color: _colorFromInt(_int(map, BackendField.color)),
    );
  }

  static Map<String, Object> capsuleMemoryToMap(CapsuleMemory memory) {
    return {
      BackendField.friendName: memory.friendName,
      BackendField.title: memory.title,
      BackendField.caption: memory.caption,
      BackendField.color: _colorToInt(memory.color),
      BackendField.unlocked: memory.unlocked,
    };
  }

  static CapsuleMemory capsuleMemoryFromMap(Map<String, Object?> map) {
    return CapsuleMemory(
      friendName: _string(map, BackendField.friendName),
      title: _string(map, BackendField.title),
      caption: _string(map, BackendField.caption),
      color: _colorFromInt(_int(map, BackendField.color)),
      unlocked: _bool(map, BackendField.unlocked),
    );
  }

  static int _colorToInt(Color color) {
    return color.toARGB32();
  }

  static Color _colorFromInt(int value) {
    return Color(value);
  }

  static String _string(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is String) {
      return value;
    }

    throw FormatException('Expected string for "$key".');
  }

  static bool _bool(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is bool) {
      return value;
    }

    throw FormatException('Expected bool for "$key".');
  }

  static int _int(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is int) {
      return value;
    }

    throw FormatException('Expected int for "$key".');
  }

  static double _double(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    throw FormatException('Expected number for "$key".');
  }
}
