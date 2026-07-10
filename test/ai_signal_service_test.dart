import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/features/base/models/signal_record.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';
import 'package:starpath/shared/ai/ai_prompt_builder.dart';
import 'package:starpath/shared/ai/mock_ai_signal_service.dart';
import 'package:starpath/shared/ai/models/ai_signal_request.dart';

void main() {
  final focusPlanet = FriendPlanet(
    id: 'emma',
    name: 'EX-002',
    energy: 0.68,
    unlocked: false,
    color: Colors.cyanAccent,
    radius: 140,
    offset: 2,
    formation: 'Sport',
  );

  const signals = [
    SignalRecord(
      friendName: 'EX-002',
      title: 'Late-night orbit ping',
      summary: 'Recent replies cluster at night.',
      energyDelta: 0.15,
      color: Colors.cyanAccent,
    ),
  ];

  test('prompt builder includes focus planet and safety rules', () {
    final request = AiSignalRequest(focusPlanet: focusPlanet, signals: signals);

    final prompt = const AiPromptBuilder().buildIcebreakerPrompt(request);

    expect(prompt, contains('Name: EX-002'));
    expect(prompt, contains('Energy: 68%'));
    expect(prompt, contains('Late-night orbit ping'));
    expect(prompt, contains('Do not mention metrics'));
  });

  test('mock AI service returns structured response', () {
    final response = const MockAiSignalService().generateIcebreaker(
      AiSignalRequest(focusPlanet: focusPlanet, signals: signals),
    );

    expect(response.suggestion, contains('soft invite'));
    expect(response.reason, contains('High energy'));
    expect(response.confidence, greaterThan(0.8));
  });

  test('legacy suggestion method still supports the current UI', () {
    final suggestion = const MockAiSignalService().suggestionFor([
      focusPlanet,
    ], signals);

    expect(suggestion, contains('soft invite'));
  });
}
