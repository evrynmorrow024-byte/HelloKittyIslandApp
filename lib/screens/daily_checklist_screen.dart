import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/models/daily_task.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/daily_task_service.dart';

class DailyChecklistScreen extends StatefulWidget {
  const DailyChecklistScreen({super.key});

  @override
  State<DailyChecklistScreen> createState() => _DailyChecklistScreenState();
}

class _DailyChecklistScreenState extends State<DailyChecklistScreen> {
  late DailyTaskService _dailyTaskService;
  List<DailyTask> _dailyTasks = [];
  List<DailyTask> _dailyQuests = [];
  List<DailyTask> _weeklyQuests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storage = await StorageService.getInstance();
    _dailyTaskService = DailyTaskService(storage);
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    try {
      final dailyTasks = await _dailyTaskService.getTasksByCategory('daily_tasks');
      final dailyQuests = await _dailyTaskService.getTasksByCategory('daily_quests');
      final weeklyQuests = await _dailyTaskService.getTasksByCategory('weekly_quests');
      
      setState(() {
        _dailyTasks = dailyTasks;
        _dailyQuests = dailyQuests;
        _weeklyQuests = weeklyQuests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(String taskId) async {
    await _dailyTaskService.toggleTaskCompletion(taskId);
    await _loadTasks();
  }

  Future<void> _addTask(String category) async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SanrioColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add New Task',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter task description...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SanrioColors.lightText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: SanrioColors.pastelPink),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: SanrioColors.brightPink, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SanrioColors.lightText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final newTask = DailyTask(
                  id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                  userId: 'user_1',
                  title: controller.text,
                  isCompleted: false,
                  category: category,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                await _dailyTaskService.addTask(newTask);
                Navigator.of(context).pop();
                await _loadTasks();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SanrioColors.brightPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelPink,
        elevation: 0,
        title: Text(
          'Daily Checklist',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SanrioColors.brightPink,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTasks,
              color: SanrioColors.brightPink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 84),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskSection(
                      'Daily Tasks', 
                      _dailyTasks, 
                      SanrioColors.pastelMint,
                      'daily_tasks',
                      '🌱',
                    ),
                    const SizedBox(height: 24),
                    _buildTaskSection(
                      'Daily Quests', 
                      _dailyQuests, 
                      SanrioColors.pastelBlue,
                      'daily_quests',
                      '⚡',
                    ),
                    const SizedBox(height: 24),
                    _buildTaskSection(
                      'Weekly Quests', 
                      _weeklyQuests, 
                      SanrioColors.pastelYellow,
                      'weekly_quests',
                      '🏆',
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTaskSection(String title, List<DailyTask> tasks, Color backgroundColor, String category, String emoji) {
    final completedCount = tasks.where((task) => task.isCompleted).length;
    
    return KawaiiCard(
      backgroundColor: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$completedCount/${tasks.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SanrioColors.lightText,
                ),
              ),
              IconButton(
                onPressed: () => _addTask(category),
                icon: const Icon(Icons.add_circle, color: SanrioColors.brightPink),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No tasks yet! Tap + to add some.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SanrioColors.lightText,
                  ),
                ),
              ),
            )
          else
            ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: KawaiiCheckbox(
                      value: task.isCompleted,
                      text: task.title,
                      onChanged: (_) => _toggleTask(task.id),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _dailyTaskService.deleteTask(task.id);
                      await _loadTasks();
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: SanrioColors.lightText,
                      size: 20,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}