import '../features/base/models/signal_record.dart';
import '../features/capsule/models/capsule_memory.dart';
import '../features/orbit/models/friend_planet.dart';

abstract class FriendRepository {
  List<FriendPlanet> loadPlanets();
}

abstract class SignalRepository {
  List<SignalRecord> loadSignals();
}

abstract class CapsuleRepository {
  List<CapsuleMemory> loadMemories();
}
