import 'package:island_trails/models/collectible.dart';
import 'package:island_trails/services/storage_service.dart';

import 'package:flutter/material.dart';
import 'package:island_trails/models/collectible.dart';
import 'package:island_trails/models/collectible_hub.dart';
import 'package:island_trails/services/storage_service.dart';

class CollectibleService {
  static const String _storageKey = 'collectibles'; // legacy flat items
  static const String _sectionsKey = 'collectible_sections'; // new hierarchical data
  final StorageService _storage;

  CollectibleService(this._storage);

  // ---------- New hierarchical API ----------
  Future<List<CollectibleSection>> getSections() async {
    final jsonList = _storage.getJsonList(_sectionsKey);
    if (jsonList != null) {
      return jsonList.map((e) => CollectibleSection.fromJson(e)).toList();
    }
    final seed = _seedSections();
    await _saveSections(seed);
    return seed;
  }

  Future<void> addSection(String title) async {
    final sections = await getSections();
    final now = DateTime.now();
    sections.add(CollectibleSection(
      id: 'section_${now.millisecondsSinceEpoch}',
      title: title,
      icon: null,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));
    await _saveSections(sections);
  }

  Future<void> addSubsection(String sectionId, String title) async {
    final sections = await getSections();
    final idx = sections.indexWhere((s) => s.id == sectionId);
    if (idx == -1) return;
    final now = DateTime.now();
    final sec = sections[idx];
    final updatedSubs = List<CollectibleSubsection>.from(sec.subsections)
      ..add(CollectibleSubsection(
        id: 'sub_${now.millisecondsSinceEpoch}',
        title: title,
        items: const [],
        createdAt: now,
        updatedAt: now,
      ));
    sections[idx] = sec.copyWith(subsections: updatedSubs, updatedAt: now);
    await _saveSections(sections);
  }

  Future<void> addItem({required String sectionId, String? subsectionId, required String name}) async {
    final sections = await getSections();
    final sIdx = sections.indexWhere((s) => s.id == sectionId);
    if (sIdx == -1) return;
    final now = DateTime.now();
    final item = CollectibleItem(
      id: 'item_${now.millisecondsSinceEpoch}',
      name: name,
      isCollected: false,
      createdAt: now,
      updatedAt: now,
    );

    final sec = sections[sIdx];
    if (subsectionId == null) {
      final updatedItems = List<CollectibleItem>.from(sec.items)..add(item);
      sections[sIdx] = sec.copyWith(items: updatedItems, updatedAt: now);
    } else {
      final subIdx = sec.subsections.indexWhere((x) => x.id == subsectionId);
      if (subIdx == -1) return;
      final sub = sec.subsections[subIdx];
      final updatedSubItems = List<CollectibleItem>.from(sub.items)..add(item);
      final updatedSub = sub.copyWith(items: updatedSubItems, updatedAt: now);
      final updatedSubs = List<CollectibleSubsection>.from(sec.subsections);
      updatedSubs[subIdx] = updatedSub;
      sections[sIdx] = sec.copyWith(subsections: updatedSubs, updatedAt: now);
    }
    await _saveSections(sections);
  }

  Future<void> toggleItem({required String sectionId, String? subsectionId, required String itemId}) async {
    final sections = await getSections();
    final sIdx = sections.indexWhere((s) => s.id == sectionId);
    if (sIdx == -1) return;
    final now = DateTime.now();
    final sec = sections[sIdx];

    if (subsectionId == null) {
      final items = List<CollectibleItem>.from(sec.items);
      final iIdx = items.indexWhere((i) => i.id == itemId);
      if (iIdx == -1) return;
      final it = items[iIdx];
      items[iIdx] = it.copyWith(isCollected: !it.isCollected, updatedAt: now);
      sections[sIdx] = sec.copyWith(items: items, updatedAt: now);
    } else {
      final subIdx = sec.subsections.indexWhere((x) => x.id == subsectionId);
      if (subIdx == -1) return;
      final sub = sec.subsections[subIdx];
      final items = List<CollectibleItem>.from(sub.items);
      final iIdx = items.indexWhere((i) => i.id == itemId);
      if (iIdx == -1) return;
      final it = items[iIdx];
      items[iIdx] = it.copyWith(isCollected: !it.isCollected, updatedAt: now);
      final updatedSub = sub.copyWith(items: items, updatedAt: now);
      final updatedSubs = List<CollectibleSubsection>.from(sec.subsections);
      updatedSubs[subIdx] = updatedSub;
      sections[sIdx] = sec.copyWith(subsections: updatedSubs, updatedAt: now);
    }
    await _saveSections(sections);
  }

  Future<int> getHierarchicalProgress() async {
    final sections = await getSections();
    int total = 0;
    int collected = 0;
    for (final s in sections) {
      for (final i in s.items) {
        total += 1;
        if (i.isCollected) collected += 1;
      }
      for (final sub in s.subsections) {
        for (final i in sub.items) {
          total += 1;
          if (i.isCollected) collected += 1;
        }
      }
    }
    return total > 0 ? ((collected / total) * 100).round() : 0;
  }

  Future<void> _saveSections(List<CollectibleSection> sections) async {
    await _storage.setJsonList(_sectionsKey, sections.map((e) => e.toJson()).toList());
  }

  List<CollectibleSection> _seedSections() {
    final now = DateTime.now();
    List<CollectibleSection> sections = [];

    List<String> events = [
      'Scholastic Celebration',
      'Friendship Festival',
      'Under The Sea Celebration',
      'Imagination Celebration',
      'Month of Meh',
      'Sunshine Celebration',
      'Colorblaze Carnival',
      'Springtime Celebration',
      'Paper Parade',
      'Happy Haven Days',
      'Luck and Lanterns',
      'Hugs and Hearts',
      'Jam Jamboree',
      'Fashion Frenzy',
      'Lighttime Jubilee',
      'Spooky Celebration',
      'Give and Gather',
    ];

    sections.add(CollectibleSection(
      id: 'sec_events',
      title: 'Events',
      icon: Icons.event,
      subsections: events
          .map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now))
          .toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_balloons',
      title: 'Balloons',
      icon: Icons.toys,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_birthdays',
      title: 'Birthdays',
      icon: Icons.cake,
      subsections: const [], // user will add subsections later
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_character_hats',
      title: 'Character Hats',
      icon: Icons.emoji_emotions,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_clothing',
      title: 'Clothing',
      icon: Icons.checkroom,
      subsections: [
        'Tops', 'Bottoms', 'Back Accessories', 'Face Accessories', 'Full Body Outfits', 'Hats',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_comics',
      title: 'Comics',
      icon: Icons.menu_book,
      subsections: [
        'The Adventures',
        'Froggy Power',
        'Badtz-Maru',
        'Ichigoman Chronicles',
        'The Incredible Hello Kitty',
        'Darkgrapeman',
        'Amazing My Melody',
        'Fantastic Friends',
        'Danger Doodler',
        'The Great Gudetama',
        'Flower Rangers',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_critters',
      title: 'Critters',
      icon: Icons.bug_report,
      subsections: [
        'Seaside Resort Critters',
        'Mount Hothead Critters',
        'Spooky Swamp Critters',
        'Gemstone Mountain Critters',
        'Rainbow Reef Critters',
        'Merry Meadow Critters',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_fish',
      title: 'Fish',
      icon: Icons.set_meal,
      subsections: [
        'Seaside Critter Fish',
        'Mount Hothead Fish',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_fish_almanacs',
      title: 'Fish Almanacs',
      icon: Icons.book,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_flowers',
      title: 'Flowers',
      icon: Icons.local_florist,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_food',
      title: 'Food',
      icon: Icons.fastfood,
      subsections: [
        'Soda Fountain',
        'Espresso Machine',
        'Pizza Oven',
        'Oven',
        'Dessert Machine',
        'Egg Pan Station',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_furniture',
      title: 'Furniture',
      icon: Icons.chair,
      subsections: [
        'Kawaii Furniture',
        'Coastal Furniture',
        'Antique Furniture',
        'Spooky Furniture',
        'Rustic Furniture',
        'Hello Kitty Furniture',
        'Nordic Furniture',
        'Basics',
        'Kuromi Furniture',
        'Tropical Furniture',
        'My Melody Furniture',
        'Meadow Furniture',
        'Pirate Furniture',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_instructions',
      title: 'Instructions',
      icon: Icons.integration_instructions,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_music_discs',
      title: 'Music Discs',
      icon: Icons.album,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_plans',
      title: 'Plans',
      icon: Icons.description,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_potions',
      title: 'Potions',
      icon: Icons.science,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_recipes',
      title: 'Recipes',
      icon: Icons.restaurant_menu,
      subsections: [
        'Cauldron',
        'Soda Fountain',
        'Espresso Machine',
        'Pizza Oven',
        'Oven',
        'Dessert Machine',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_tools',
      title: 'Tools',
      icon: Icons.handyman,
      subsections: const [],
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_trinkets',
      title: 'Trinkets',
      icon: Icons.auto_awesome,
      subsections: [
        'Trinkets',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_weather',
      title: 'Weather',
      icon: Icons.wb_sunny,
      subsections: [
        'Aquafall Machine',
        'Celestree',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    sections.add(CollectibleSection(
      id: 'sec_wheatflour_wonderland',
      title: 'Wheatflour Wonderland',
      icon: Icons.park,
      subsections: [
        'Wheatflour Wonderland Critters',
        'Revolutionary Fairy',
      ].map((t) => CollectibleSubsection(id: 'sub_${t.hashCode}', title: t, items: const [], createdAt: now, updatedAt: now)).toList(),
      items: const [],
      createdAt: now,
      updatedAt: now,
    ));

    return sections;
  }

  // ---------- Legacy flat API (kept for backward-compatibility in other parts) ----------
  Future<List<Collectible>> getAllCollectibles() async {
    final jsonList = _storage.getJsonList(_storageKey);
    if (jsonList != null) {
      return jsonList.map((json) => Collectible.fromJson(json)).toList();
    }
    final sampleCollectibles = _getSampleCollectibles();
    await _saveCollectibles(sampleCollectibles);
    return sampleCollectibles;
  }

  Future<List<Collectible>> getCollectiblesByCategory(String category) async {
    final collectibles = await getAllCollectibles();
    return collectibles.where((collectible) => collectible.category == category).toList();
  }

  Future<void> toggleCollectibleStatus(String id) async {
    final collectibles = await getAllCollectibles();
    final collectibleIndex = collectibles.indexWhere((collectible) => collectible.id == id);
    if (collectibleIndex != -1) {
      final collectible = collectibles[collectibleIndex];
      final updatedCollectible = collectible.copyWith(
        isCollected: !collectible.isCollected,
        updatedAt: DateTime.now(),
      );
      collectibles[collectibleIndex] = updatedCollectible;
      await _saveCollectibles(collectibles);
    }
  }

  Future<int> getCollectionProgress() async {
    final collectibles = await getAllCollectibles();
    final collected = collectibles.where((c) => c.isCollected).length;
    final total = collectibles.length;
    return total > 0 ? ((collected / total) * 100).round() : 0;
  }

  Future<void> _saveCollectibles(List<Collectible> collectibles) async {
    final jsonList = collectibles.map((collectible) => collectible.toJson()).toList();
    await _storage.setJsonList(_storageKey, jsonList);
  }

  List<Collectible> _getSampleCollectibles() {
    final now = DateTime.now();
    const userId = 'user_1';
    return [
      Collectible(
        id: 'recipe_1',
        userId: userId,
        name: 'Apple Pie',
        category: 'recipes',
        isCollected: false,
        description: 'Hello Kitty\'s favorite dessert',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
