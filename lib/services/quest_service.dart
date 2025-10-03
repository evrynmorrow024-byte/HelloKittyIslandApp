import 'package:island_trails/models/quest.dart';
import 'package:island_trails/services/storage_service.dart';

class QuestService {
  static const String _storageKey = 'quests';
  final StorageService _storage;

  QuestService(this._storage);

  Future<List<Quest>> getAllQuests() async {
    final jsonList = _storage.getJsonList(_storageKey);
    if (jsonList != null) {
      return jsonList.map((json) => Quest.fromJson(json)).toList();
    }
    
    // Initialize with sample data
    final sampleQuests = _getSampleQuests();
    await _saveQuests(sampleQuests);
    return sampleQuests;
  }

  Future<List<Quest>> getQuestsByCategory(String category) async {
    final quests = await getAllQuests();
    return quests.where((quest) => quest.category == category).toList();
  }

  Future<void> updateQuest(Quest updatedQuest) async {
    final quests = await getAllQuests();
    final index = quests.indexWhere((quest) => quest.id == updatedQuest.id);
    if (index != -1) {
      quests[index] = updatedQuest;
      await _saveQuests(quests);
    }
  }

  Future<void> toggleQuestStepCompletion(String questId, int stepIndex) async {
    final quests = await getAllQuests();
    final questIndex = quests.indexWhere((quest) => quest.id == questId);
    if (questIndex != -1) {
      final quest = quests[questIndex];
      final newStepCompletions = List<bool>.from(quest.stepCompletions);
      newStepCompletions[stepIndex] = !newStepCompletions[stepIndex];
      
      final isCompleted = newStepCompletions.every((completed) => completed);
      
      final updatedQuest = quest.copyWith(
        stepCompletions: newStepCompletions,
        isCompleted: isCompleted,
        updatedAt: DateTime.now(),
      );
      
      quests[questIndex] = updatedQuest;
      await _saveQuests(quests);
    }
  }

  Future<void> _saveQuests(List<Quest> quests) async {
    final jsonList = quests.map((quest) => quest.toJson()).toList();
    await _storage.setJsonList(_storageKey, jsonList);
  }

  List<Quest> _getSampleQuests() {
    final now = DateTime.now();
    const userId = 'user_1';
    
    return [
      // Island Mystery
      Quest(
        id: 'mystery_1',
        userId: userId,
        title: 'The Great Island Mystery',
        category: 'island_mystery',
        isCompleted: false,
        steps: [
          'Talk to Hello Kitty about the strange sounds',
          'Investigate the mysterious cave',
          'Find the hidden treasure map',
          'Solve the ancient puzzle',
          'Discover the island\'s secret'
        ],
        stepCompletions: [false, false, false, false, false],
        createdAt: now,
        updatedAt: now,
      ),
      
      // Right Tools
      Quest(
        id: 'tools_1',
        userId: userId,
        title: 'Getting the Right Tools',
        category: 'right_tools',
        isCompleted: false,
        steps: [
          'Find the magical hammer',
          'Collect rare gemstones',
          'Craft the perfect fishing rod',
          'Upgrade your gardening tools'
        ],
        stepCompletions: [false, false, false, false],
        createdAt: now,
        updatedAt: now,
      ),
      
      // Around The Island
      Quest(
        id: 'around_1',
        userId: userId,
        title: 'Island Explorer',
        category: 'around_island',
        isCompleted: false,
        steps: [
          'Visit the Rainbow Falls',
          'Explore the Enchanted Forest',
          'Climb Mount Meow',
          'Swim in Crystal Lagoon',
          'Find all hidden photo spots'
        ],
        stepCompletions: [false, false, false, false, false],
        createdAt: now,
        updatedAt: now,
      ),
      
      // Friendship Quests
      Quest(
        id: 'friendship_1',
        userId: userId,
        title: 'Best Friends Forever',
        category: 'friendship',
        isCompleted: false,
        steps: [
          'Reach level 5 with Hello Kitty',
          'Help My Melody with her garden',
          'Play games with Kuromi',
          'Have a tea party with everyone'
        ],
        stepCompletions: [false, false, false, false],
        createdAt: now,
        updatedAt: now,
      ),
      
      // Wheatflour Wonderland
      Quest(
        id: 'wheatflour_1',
        userId: userId,
        title: 'Baking Adventure',
        category: 'wheatflour',
        isCompleted: false,
        steps: [
          'Plant wheat seeds',
          'Harvest golden wheat',
          'Mill flour at the windmill',
          'Bake Hello Kitty\'s favorite cookies',
          'Share treats with all friends'
        ],
        stepCompletions: [false, false, false, false, false],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}