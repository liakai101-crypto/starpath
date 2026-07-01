import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TimePhysicsSnapshot {
  const TimePhysicsSnapshot({
    required this.pulseCooldownUntil,
    required this.hibernateStartTime,
    required this.lastInteractionAt,
    required this.solarPhotonWatts,
    required this.planetEnergies,
    required this.isHibernating,
  });

  final DateTime? pulseCooldownUntil;
  final DateTime? hibernateStartTime;
  final DateTime? lastInteractionAt;
  final int solarPhotonWatts;
  final List<double> planetEnergies;
  final bool isHibernating;
}

class TimePhysicsStorage {
  const TimePhysicsStorage();

  static const String _pulseCooldownUntilKey = 'pulseCooldownUntil';
  static const String _hibernateStartTimeKey = 'hibernateStartTime';
  static const String _lastInteractionAtKey = 'lastInteractionAt';
  static const String _solarPhotonWattsKey = 'solarPhotonWatts';
  static const String _planetEnergiesKey = 'planetEnergies';
  static const String _isHibernatingKey = 'isHibernating';

  Future<TimePhysicsSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    return TimePhysicsSnapshot(
      pulseCooldownUntil: _readDate(prefs, _pulseCooldownUntilKey),
      hibernateStartTime: _readDate(prefs, _hibernateStartTimeKey),
      lastInteractionAt: _readDate(prefs, _lastInteractionAtKey),
      solarPhotonWatts: prefs.getInt(_solarPhotonWattsKey) ?? 0,
      planetEnergies: _readEnergies(prefs),
      isHibernating: prefs.getBool(_isHibernatingKey) ?? false,
    );
  }

  Future<void> save({
    required DateTime? pulseCooldownUntil,
    required DateTime? hibernateStartTime,
    required DateTime? lastInteractionAt,
    required int solarPhotonWatts,
    required List<double> planetEnergies,
    required bool isHibernating,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeDate(prefs, _pulseCooldownUntilKey, pulseCooldownUntil);
    await _writeDate(prefs, _hibernateStartTimeKey, hibernateStartTime);
    await _writeDate(prefs, _lastInteractionAtKey, lastInteractionAt);
    await prefs.setInt(_solarPhotonWattsKey, solarPhotonWatts);
    await prefs.setString(_planetEnergiesKey, jsonEncode(planetEnergies));
    await prefs.setBool(_isHibernatingKey, isHibernating);
  }

  DateTime? _readDate(SharedPreferences prefs, String key) {
    final value = prefs.getString(key);
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<void> _writeDate(
    SharedPreferences prefs,
    String key,
    DateTime? value,
  ) async {
    if (value == null) {
      await prefs.remove(key);
      return;
    }

    await prefs.setString(key, value.toIso8601String());
  }

  List<double> _readEnergies(SharedPreferences prefs) {
    final value = prefs.getString(_planetEnergiesKey);
    if (value == null) {
      return const [];
    }

    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return const [];
    }

    return decoded.whereType<num>().map((energy) => energy.toDouble()).toList();
  }
}
