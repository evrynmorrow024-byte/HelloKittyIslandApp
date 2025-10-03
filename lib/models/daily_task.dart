class DailyTask {
  final String id;
  final String userId;
  final String title;
  final bool isCompleted;
  final String category; // 'daily_tasks', 'daily_quests', 'weekly_quests'
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyTask({
    required this.id,
    required this.userId,
    required this.title,
    required this.isCompleted,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'is_completed': isCompleted,
    'category': category,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    isCompleted: json['is_completed'] as bool,
    category: json['category'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  DailyTask copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyTask(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}