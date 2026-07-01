import '../features/base/models/signal_record.dart';
import '../features/capsule/models/capsule_memory.dart';
import '../features/orbit/models/friend_planet.dart';
import 'repositories.dart';
import 'starpath_mock_data.dart';

class MockFriendRepository implements FriendRepository {
  const MockFriendRepository();

  @override
  List<FriendPlanet> loadPlanets() {
    return StarPathMockData.planets();
  }
}

class MockSignalRepository implements SignalRepository {
  const MockSignalRepository();

  @override
  List<SignalRecord> loadSignals() {
    return StarPathMockData.signals();
  }
}

class MockCapsuleRepository implements CapsuleRepository {
  const MockCapsuleRepository();

  @override
  List<CapsuleMemory> loadMemories() {
    return StarPathMockData.memories();
  }
}
