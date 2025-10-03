class Collectible {
  final String id;
  final String userId;
  final String name;
  final String category; // 'recipes', 'critters', 'outfits', 'photo_spots'
  final bool isCollected;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Collectible({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.isCollected,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'category': category,
    'is_collected': isCollected,
    'description': description,
    'image_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Collectible.fromJson(Map<String, dynamic> json) => Collectible(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    isCollected: json['is_collected'] as bool,
    description: json['description'] as String?,
    imageUrl: json['image_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Collectible copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    bool? isCollected,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Collectible(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    category: category ?? this.category,
    isCollected: isCollected ?? this.isCollected,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}