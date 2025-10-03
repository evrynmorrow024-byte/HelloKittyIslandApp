class Character {
  final String id;
  final String name;
  final String imageUrl;
  final String birthday;
  final String favoriteGift;
  final List<String> relationships;
  final int currentFriendshipLevel;
  final List<FriendshipLevel> friendshipLevels;
  final bool isUnlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Character({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.birthday,
    required this.favoriteGift,
    required this.relationships,
    required this.currentFriendshipLevel,
    required this.friendshipLevels,
    required this.isUnlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image_url': imageUrl,
    'birthday': birthday,
    'favorite_gift': favoriteGift,
    'relationships': relationships,
    'current_friendship_level': currentFriendshipLevel,
    'friendship_levels': friendshipLevels.map((e) => e.toJson()).toList(),
    'is_unlocked': isUnlocked,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as String,
    name: json['name'] as String,
    imageUrl: json['image_url'] as String,
    birthday: json['birthday'] as String,
    favoriteGift: json['favorite_gift'] as String,
    relationships: List<String>.from(json['relationships'] as List),
    currentFriendshipLevel: json['current_friendship_level'] as int,
    friendshipLevels: (json['friendship_levels'] as List)
        .map((e) => FriendshipLevel.fromJson(e as Map<String, dynamic>))
        .toList(),
    isUnlocked: (json['is_unlocked'] ?? false) == true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Character copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? birthday,
    String? favoriteGift,
    List<String>? relationships,
    int? currentFriendshipLevel,
    List<FriendshipLevel>? friendshipLevels,
    bool? isUnlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Character(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl ?? this.imageUrl,
    birthday: birthday ?? this.birthday,
    favoriteGift: favoriteGift ?? this.favoriteGift,
    relationships: relationships ?? this.relationships,
    currentFriendshipLevel: currentFriendshipLevel ?? this.currentFriendshipLevel,
    friendshipLevels: friendshipLevels ?? this.friendshipLevels,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class FriendshipLevel {
  final int level;
  final String reward;
  final List<String> requirements;
  final List<bool> requirementCompletions;

  FriendshipLevel({
    required this.level,
    required this.reward,
    required this.requirements,
    required this.requirementCompletions,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'reward': reward,
    'requirements': requirements,
    'requirement_completions': requirementCompletions,
  };

  factory FriendshipLevel.fromJson(Map<String, dynamic> json) => FriendshipLevel(
    level: json['level'] as int,
    reward: json['reward'] as String,
    requirements: List<String>.from(json['requirements'] as List),
    requirementCompletions: List<bool>.from(json['requirement_completions'] as List),
  );

  FriendshipLevel copyWith({
    int? level,
    String? reward,
    List<String>? requirements,
    List<bool>? requirementCompletions,
  }) => FriendshipLevel(
    level: level ?? this.level,
    reward: reward ?? this.reward,
    requirements: requirements ?? this.requirements,
    requirementCompletions: requirementCompletions ?? this.requirementCompletions,
  );
}
