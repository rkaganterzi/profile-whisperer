class AnalysisResult {
  final String id;
  final String vibeType;
  final String vibeEmoji;
  final String description;
  final String roast;
  final List<String> redFlags;
  final List<String> greenFlags;
  final List<String> traits;
  final List<String> conversationStarters;
  final String energy;
  final String compatibility;
  final DateTime createdAt;

  AnalysisResult({
    required this.id,
    required this.vibeType,
    required this.vibeEmoji,
    required this.description,
    required this.roast,
    required this.redFlags,
    required this.greenFlags,
    required this.traits,
    required this.conversationStarters,
    required this.energy,
    required this.compatibility,
    required this.createdAt,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] ?? '',
      vibeType: json['vibe_type'] ?? 'Unknown Vibe',
      vibeEmoji: json['vibe_emoji'] ?? '✨',
      description: json['description'] ?? '',
      roast: json['roast'] ?? '',
      redFlags: List<String>.from(json['red_flags'] ?? []),
      greenFlags: List<String>.from(json['green_flags'] ?? []),
      traits: List<String>.from(json['traits'] ?? []),
      conversationStarters: List<String>.from(json['conversation_starters'] ?? []),
      energy: json['energy'] ?? 'Neutral',
      compatibility: json['compatibility'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vibe_type': vibeType,
      'vibe_emoji': vibeEmoji,
      'description': description,
      'roast': roast,
      'red_flags': redFlags,
      'green_flags': greenFlags,
      'traits': traits,
      'conversation_starters': conversationStarters,
      'energy': energy,
      'compatibility': compatibility,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
