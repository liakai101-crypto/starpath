import '../../../features/base/models/signal_record.dart';
import '../../../features/orbit/models/friend_planet.dart';

class AiSignalRequest {
  const AiSignalRequest({
    required this.focusPlanet,
    required this.signals,
    this.tone = 'warm, playful, low-pressure',
    this.goal = 'suggest one natural icebreaker message',
  });

  final FriendPlanet focusPlanet;
  final List<SignalRecord> signals;
  final String tone;
  final String goal;
}
