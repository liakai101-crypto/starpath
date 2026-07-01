import '../../features/base/models/signal_record.dart';
import '../../features/orbit/models/friend_planet.dart';
import 'ai_prompt_builder.dart';
import 'ai_signal_service.dart';
import 'models/ai_signal_request.dart';
import 'models/ai_signal_response.dart';

class MockAiSignalService implements AiSignalService {
  const MockAiSignalService({this.promptBuilder = const AiPromptBuilder()});

  final AiPromptBuilder promptBuilder;

  @override
  String suggestionFor(List<FriendPlanet> planets, List<SignalRecord> signals) {
    final FriendPlanet focus = planets.firstWhere(
      (planet) => !planet.unlocked,
      orElse: () => planets.first,
    );

    final response = generateIcebreaker(
      AiSignalRequest(focusPlanet: focus, signals: signals),
    );

    return response.suggestion;
  }

  @override
  AiSignalResponse generateIcebreaker(AiSignalRequest request) {
    final SignalRecord signal = request.signals.firstWhere(
      (record) => record.friendName == request.focusPlanet.name,
      orElse: () => request.signals.first,
    );
    final prompt = promptBuilder.buildIcebreakerPrompt(request);

    if (request.focusPlanet.energy >= 0.65) {
      return AiSignalResponse(
        suggestion:
            'Send a soft invite: "I found something that made me think of you. Want me to send it?"',
        reason: 'High energy focus planet. Prompt length ${prompt.length}.',
        confidence: 0.86,
      );
    }

    return AiSignalResponse(
      suggestion:
          'Start with a low-pressure check-in connected to ${signal.title}.',
      reason: 'Lower energy focus planet. Prompt length ${prompt.length}.',
      confidence: 0.72,
    );
  }
}
