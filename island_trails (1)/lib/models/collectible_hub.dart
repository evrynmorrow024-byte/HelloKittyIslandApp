import 'package:flutter/material.dart';

class CollectibleItem {
  final String id;
  final String name;
  final bool isCollected;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectibleItem({
    required this.id,
    required this.name,
    required this.isCollected,
    required this.createdAt,
    required this.updatedAt,
  });

  CollectibleItem copyWith({
    String? id,
    String? name,
    bool? isCollected,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectibleItem(
    id: id ?? this.id,
    name: name ?? this.name,
    isCollected: isCollected ?? this.isCollected,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_collected': isCollected,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CollectibleItem.fromJson(Map<String, dynamic> json) => CollectibleItem(
    id: json['id'] as String,
    name: json['name'] as String,
    isCollected: (json['is_collected'] ?? false) == true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class CollectibleSubsection {
  final String id;
  final String title;
  final List<CollectibleItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectibleSubsection({
    required this.id,
    required this.title,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  CollectibleSubsection copyWith({
    String? id,
    String? title,
    List<CollectibleItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectibleSubsection(
    id: id ?? this.id,
    title: title ?? this.title,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CollectibleSubsection.fromJson(Map<String, dynamic> json) => CollectibleSubsection(
    id: json['id'] as String,
    title: json['title'] as String,
    items: ((json['items'] as List?) ?? const []).map((e) => CollectibleItem.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class CollectibleSection {
  final String id;
  final String title;
  final IconData? icon;
  final List<CollectibleSubsection> subsections;
  final List<CollectibleItem> items; // for sections without subsections
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectibleSection({
    required this.id,
    required this.title,
    this.icon,
    required this.subsections,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasSubsections => subsections.isNotEmpty;

  CollectibleSection copyWith({
    String? id,
    String? title,
    IconData? icon,
    List<CollectibleSubsection>? subsections,
    List<CollectibleItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectibleSection(
    id: id ?? this.id,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    subsections: subsections ?? this.subsections,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon?.codePoint,
    'subsections': subsections.map((e) => e.toJson()).toList(),
    'items': items.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CollectibleSection.fromJson(Map<String, dynamic> json) => CollectibleSection(
    id: json['id'] as String,
    title: json['title'] as String,
    icon: json['icon'] != null ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons') : null,
    subsections: ((json['subsections'] as List?) ?? const []).map((e) => CollectibleSubsection.fromJson(e as Map<String, dynamic>)).toList(),
    items: ((json['items'] as List?) ?? const []).map((e) => CollectibleItem.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}
