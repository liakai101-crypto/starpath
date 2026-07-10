import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/features/base/models/signal_record.dart';
import 'package:starpath/features/capsule/models/capsule_memory.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';
import 'package:starpath/services/backend/backend_collections.dart';
import 'package:starpath/services/backend/backend_field.dart';
import 'package:starpath/services/backend/starpath_serializers.dart';

void main() {
  test('backend collection names are stable', () {
    expect(BackendCollections.friends, 'friends');
    expect(BackendCollections.signals, 'signals');
    expect(BackendCollections.capsules, 'capsules');
  });

  test('friend planet serializes round-trip', () {
    final planet = FriendPlanet(
      id: 'emma',
      name: 'Navigator Emma',
      energy: 0.83,
      unlocked: true,
      color: Colors.greenAccent,
      radius: 140,
      offset: 2,
      formation: 'Sport',
    );

    final map = StarPathSerializers.friendPlanetToMap(planet);
    final restored = StarPathSerializers.friendPlanetFromMap(map);

    expect(map[BackendField.name], 'Navigator Emma');
    expect(restored.id, 'Navigator Emma');
    expect(restored.name, planet.name);
    expect(restored.energy, planet.energy);
    expect(restored.unlocked, planet.unlocked);
    expect(restored.color.toARGB32(), planet.color.toARGB32());
    expect(restored.radius, planet.radius);
    expect(restored.offset, planet.offset);
    expect(restored.formation, planet.formation);
    expect(restored.mutualGravityAccepted, isTrue);
    expect(restored.blocked, isFalse);
  });

  test('signal record serializes round-trip', () {
    const signal = SignalRecord(
      friendName: 'EX-002',
      title: 'Late-night orbit ping',
      summary: 'Keep the next message light.',
      energyDelta: 0.15,
      color: Colors.cyanAccent,
    );

    final map = StarPathSerializers.signalRecordToMap(signal);
    final restored = StarPathSerializers.signalRecordFromMap(map);

    expect(restored.friendName, signal.friendName);
    expect(restored.title, signal.title);
    expect(restored.summary, signal.summary);
    expect(restored.energyDelta, signal.energyDelta);
    expect(restored.color.toARGB32(), signal.color.toARGB32());
  });

  test('capsule memory serializes round-trip', () {
    const memory = CapsuleMemory(
      friendName: 'Cpt. Alex',
      title: 'Meteor Cafe',
      caption: 'The afternoon you both forgot to check the time.',
      color: Colors.greenAccent,
      unlocked: true,
    );

    final map = StarPathSerializers.capsuleMemoryToMap(memory);
    final restored = StarPathSerializers.capsuleMemoryFromMap(map);

    expect(restored.friendName, memory.friendName);
    expect(restored.title, memory.title);
    expect(restored.caption, memory.caption);
    expect(restored.color.toARGB32(), memory.color.toARGB32());
    expect(restored.unlocked, memory.unlocked);
  });
}
