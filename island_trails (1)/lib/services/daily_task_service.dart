import 'package:island_trails/models/daily_task.dart';
import 'package:island_trails/services/storage_service.dart';

class DailyTaskService {
  static const String _storageKey = 'daily_tasks';
  final StorageService _storage;

  DailyTaskService(this._storage);

  Future<List<DailyTask>> getAllTasks() async {
    final jsonList = _storage.getJsonList(_storageKey);
    if (jsonList != null) {
      return jsonList.map((json) => DailyTask.fromJson(json)).toList();
    }
    
    // Initialize with sample data
    final sampleTasks = _getSampleTasks();
    await _saveTasks(sampleTasks);
    return sampleTasks;
  }

  Future<List<DailyTask>> getTasksByCategory(String category) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.category == category).toList();
  }

  Future<void> addTask(DailyTask task) async {
    final tasks = await getAllTasks();
    tasks.add(task);
    await _saveTasks(tasks);
  }

  Future<void> updateTask(DailyTask updatedTask) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await _saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final tasks = await getAllTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );
      tasks[taskIndex] = updatedTask;
      await _saveTasks(tasks);
    }
  }

  Future<void> _saveTasks(List<DailyTask> tasks) async {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await _storage.setJsonList(_storageKey, jsonList);
  }

  List<DailyTask> _getSampleTasks() {
    final now = DateTime.now();
    const userId = 'user_1';
    
    return [
      // Daily Tasks
      DailyTask(
        id: 'daily_1',
        userId: userId,
        title: 'Water all flowers',
        isCompleted: false,
        category: 'daily_tasks',
        createdAt: now,
        updatedAt: now,
      ),
      DailyTask(
        id: 'daily_2',
        userId: userId,
        title: 'Feed all animals',
        isCompleted: false,
        category: 'daily_tasks',
        createdAt: now,
        updatedAt: now,
      ),
      DailyTask(
        id: 'daily_3',
        userId: userId,
        title: 'Check the shop',
        isCompleted: false,
        category: 'daily_tasks',
        createdAt: now,
        updatedAt: now,
      ),
      // Daily Quests
      DailyTask(
        id: 'daily_quest_1',
        userId: userId,
        title: 'Complete 3 friendship activities',
        isCompleted: false,
        category: 'daily_quests',
        createdAt: now,
        updatedAt: now,
      ),
      DailyTask(
        id: 'daily_quest_2',
        userId: userId,
        title: 'Catch 5 critters',
        isCompleted: false,
        category: 'daily_quests',
        createdAt: now,
        updatedAt: now,
      ),
      // Weekly Quests
      DailyTask(
        id: 'weekly_quest_1',
        userId: userId,
        title: 'Complete 10 friendship levels',
        isCompleted: false,
        category: 'weekly_quests',
        createdAt: now,
        updatedAt: now,
      ),
      DailyTask(
        id: 'weekly_quest_2',
        userId: userId,
        title: 'Collect 25 new items',
        isCompleted: false,
        category: 'weekly_quests',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}