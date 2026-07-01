import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starpath/core/starpath_controller.dart';
import 'package:starpath/services/mock_repositories.dart';
import 'package:starpath/services/time_physics_storage.dart';
import 'package:starpath/shared/ai/mock_ai_signal_service.dart';

void main() {
  StarPathController controller() {
    return StarPathController(
      friendRepository: const MockFriendRepository(),
      signalRepository: const MockSignalRepository(),
      capsuleRepository: const MockCapsuleRepository(),
      aiSignalService: const MockAiSignalService(),
      timePhysicsStorage: const TimePhysicsStorage(),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('hibernation state is persisted', () async {
    final first = controller();
    await first.initializePhysics();

    first.toggleHibernation();
    await Future<void>.delayed(Duration.zero);

    final second = controller();
    await second.initializePhysics();

    expect(second.isHibernating, isTrue);
    expect(second.hibernateStartTime, isNotNull);
  });

  test('waking from hibernation grants solar photon watts', () async {
    final start = DateTime.now().subtract(const Duration(seconds: 5));
    SharedPreferences.setMockInitialValues({
      'isHibernating': true,
      'hibernateStartTime': start.toIso8601String(),
    });

    final appState = controller();
    await appState.initializePhysics();
    appState.toggleHibernation();

    expect(appState.isHibernating, isFalse);
    expect(appState.solarPhotonWatts, greaterThanOrEqualTo(60));
  });

  test(
    'entropy decay starts after fourteen idle days and floors at thirty',
    () async {
      final lastInteraction = DateTime.now().subtract(const Duration(days: 20));
      SharedPreferences.setMockInitialValues({
        'lastInteractionAt': lastInteraction.toIso8601String(),
        'planetEnergies': '[0.35,0.68,0.85]',
      });

      final appState = controller();
      await appState.initializePhysics();

      expect(appState.entropyLostPercent, 6);
      expect(appState.planets.first.energy, 0.30);
      expect(appState.planets[1].energy, closeTo(0.62, 0.001));
    },
  );
}
