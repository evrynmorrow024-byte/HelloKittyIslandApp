import 'package:island_trails/models/visitor.dart';
import 'package:island_trails/services/storage_service.dart';

class VisitorService {
  static const String _storageKey = 'visitors';
  final StorageService _storage;

  VisitorService(this._storage);

  Future<List<Visitor>> getAllVisitors() async {
    final jsonList = _storage.getJsonList(_storageKey);
    if (jsonList != null) {
      return jsonList.map((json) => Visitor.fromJson(json)).toList();
    }
    final sample = _getSampleVisitors();
    await _saveVisitors(sample);
    return sample;
  }

  Future<void> updateVisitor(Visitor updated) async {
    final visitors = await getAllVisitors();
    final index = visitors.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      visitors[index] = updated.copyWith(updatedAt: DateTime.now());
      await _saveVisitors(visitors);
    }
  }

  Future<void> updateStarLevel(String visitorId, int level) async {
    final visitors = await getAllVisitors();
    final idx = visitors.indexWhere((v) => v.id == visitorId);
    if (idx != -1) {
      final v = visitors[idx];
      visitors[idx] = v.copyWith(starLevel: level.clamp(0, 5), updatedAt: DateTime.now());
      await _saveVisitors(visitors);
    }
  }

  Future<void> updateHouse(String visitorId, String house) async {
    final visitors = await getAllVisitors();
    final idx = visitors.indexWhere((v) => v.id == visitorId);
    if (idx != -1) {
      final v = visitors[idx];
      visitors[idx] = v.copyWith(house: house, updatedAt: DateTime.now());
      await _saveVisitors(visitors);
    }
  }

  Future<void> toggleRequirement(String visitorId, int reqIndex) async {
    final visitors = await getAllVisitors();
    final idx = visitors.indexWhere((v) => v.id == visitorId);
    if (idx != -1) {
      final v = visitors[idx];
      final comps = List<bool>.from(v.requirementCompletions);
      final reqLen = v.requirements.length;
      if (comps.length < reqLen) {
        comps.addAll(List<bool>.filled(reqLen - comps.length, false));
      }
      if (reqIndex >= 0 && reqIndex < reqLen) {
        comps[reqIndex] = !comps[reqIndex];
        visitors[idx] = v.copyWith(requirementCompletions: comps, updatedAt: DateTime.now());
        await _saveVisitors(visitors);
      }
    }
  }

  Future<void> setUnlocked(String visitorId, bool unlocked) async {
    final visitors = await getAllVisitors();
    final idx = visitors.indexWhere((v) => v.id == visitorId);
    if (idx != -1) {
      final v = visitors[idx];
      visitors[idx] = v.copyWith(isUnlocked: unlocked, updatedAt: DateTime.now());
      await _saveVisitors(visitors);
    }
  }

  Future<void> _saveVisitors(List<Visitor> visitors) async {
    final jsonList = visitors.map((e) => e.toJson()).toList();
    await _storage.setJsonList(_storageKey, jsonList);
  }

  List<Visitor> _getSampleVisitors() {
    final now = DateTime.now();
    const userId = 'user_1';

    return [
      Visitor(
        id: 'visitor_blossom_bunny',
        userId: userId,
        name: 'Blossom Bunny',
        requirements: ['Bring 3 flowers', 'Visit the photo spot', 'Share tea time'],
        requirementCompletions: [false, false, false],
        starLevel: 0,
        house: 'Seaside Cottage',
        imageUrl: null,
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
      Visitor(
        id: 'visitor_sparkle_fox',
        userId: userId,
        name: 'Sparkle Fox',
        requirements: ['Catch 2 butterflies', 'Find shiny pebble'],
        requirementCompletions: [false, false],
        starLevel: 0,
        house: 'Forest Cabin',
        imageUrl: null,
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
