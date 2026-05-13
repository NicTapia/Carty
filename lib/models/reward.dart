class Reward {
  final String name;
  final String emoji;

  const Reward({required this.name, required this.emoji});

  factory Reward.fromDisplayText(String reward) {
    final trimmedReward = reward.trim();

    if (trimmedReward.isEmpty) {
      return const Reward(name: '', emoji: '🎁');
    }

    final firstSpaceIndex = trimmedReward.indexOf(' ');

    if (firstSpaceIndex == -1) {
      return Reward(name: trimmedReward, emoji: '🎁');
    }

    return Reward(
      emoji: trimmedReward.substring(0, firstSpaceIndex).trim(),
      name: trimmedReward.substring(firstSpaceIndex + 1).trim(),
    );
  }

  String get displayText {
    if (name.trim().isEmpty) {
      return emoji;
    }

    return '$emoji $name';
  }

  Reward copyWith({String? name, String? emoji}) {
    return Reward(name: name ?? this.name, emoji: emoji ?? this.emoji);
  }

  Map<String, Object> toJson() {
    return {'name': name, 'emoji': emoji};
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎁',
    );
  }
}
