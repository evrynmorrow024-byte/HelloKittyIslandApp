class Quest {
  final String id;
  final String userId;
  final String title;
  final String category; // 'island_mystery', 'right_tools', 'around_island', 'friendship', 'wheatflour'
  final bool isCompleted;
  final List<String> steps;
  final List<bool> stepCompletions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Quest({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.steps,
    required this.stepCompletions,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'category': category,
    'is_completed': isCompleted,
    'steps': steps,
    'step_completions': stepCompletions,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    isCompleted: json['is_completed'] as bool,
    steps: List<String>.from(json['steps'] as List),
    stepCompletions: List<bool>.from(json['step_completions'] as List),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Quest copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    bool? isCompleted,
    List<String>? steps,
    List<bool>? stepCompletions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Quest(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    category: category ?? this.category,
    isCompleted: isCompleted ?? this.isCompleted,
    steps: steps ?? this.steps,
    stepCompletions: stepCompletions ?? this.stepCompletions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}