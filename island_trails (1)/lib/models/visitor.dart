class Visitor {
  final String id;
  final String userId;
  final String name;
  final List<String> requirements;
  final List<bool> requirementCompletions;
  final int starLevel; // 0-5
  final String house;
  final String? imageUrl;
  final bool isUnlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visitor({
    required this.id,
    required this.userId,
    required this.name,
    required this.requirements,
    required this.requirementCompletions,
    required this.starLevel,
    required this.house,
    this.imageUrl,
    required this.isUnlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'requirements': requirements,
    'requirement_completions': requirementCompletions,
    'star_level': starLevel,
    'house': house,
    'image_url': imageUrl,
    'is_unlocked': isUnlocked,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    requirements: List<String>.from(json['requirements'] as List),
    requirementCompletions: List<bool>.from(json['requirement_completions'] as List),
    starLevel: json['star_level'] as int,
    house: json['house'] as String,
    imageUrl: json['image_url'] as String?,
    isUnlocked: (json['is_unlocked'] ?? false) == true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Visitor copyWith({
    String? id,
    String? userId,
    String? name,
    List<String>? requirements,
    List<bool>? requirementCompletions,
    int? starLevel,
    String? house,
    String? imageUrl,
    bool? isUnlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Visitor(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    requirements: requirements ?? this.requirements,
    requirementCompletions: requirementCompletions ?? this.requirementCompletions,
    starLevel: starLevel ?? this.starLevel,
    house: house ?? this.house,
    imageUrl: imageUrl ?? this.imageUrl,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
