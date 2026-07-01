import '../../features/base/models/signal_record.dart';
import '../../features/orbit/models/friend_planet.dart';
import 'models/ai_signal_request.dart';
import 'models/ai_signal_response.dart';

abstract class AiSignalService {
  String suggestionFor(List<FriendPlanet> planets, List<SignalRecord> signals);

  AiSignalResponse generateIcebreaker(AiSignalRequest request);
}
