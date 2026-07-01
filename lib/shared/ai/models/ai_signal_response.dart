class AiSignalResponse {
  const AiSignalResponse({
    required this.suggestion,
    required this.reason,
    required this.confidence,
  });

  final String suggestion;
  final String reason;
  final double confidence;
}
