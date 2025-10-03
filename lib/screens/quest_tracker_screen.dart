import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/models/quest.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/quest_service.dart';

class QuestTrackerScreen extends StatefulWidget {
  const QuestTrackerScreen({super.key});

  @override
  State<QuestTrackerScreen> createState() => _QuestTrackerScreenState();
}

class _QuestTrackerScreenState extends State<QuestTrackerScreen> {
  late QuestService _questService;
  List<Quest> _allQuests = [];
  bool _isLoading = true;

  final Map<String, String> _categoryNames = {
    'island_mystery': 'The Island Mystery',
    'right_tools': 'The Right Tools',
    'around_island': 'Around The Island',
    'friendship': 'Friendship Quests',
    'wheatflour': 'Wheatflour Wonderland',
  };

  final Map<String, String> _categoryEmojis = {
    'island_mystery': '🔍',
    'right_tools': '🔨',
    'around_island': '🗺️',
    'friendship': '💕',
    'wheatflour': '🌾',
  };

  final Map<String, Color> _categoryColors = {
    'island_mystery': SanrioColors.pastelLavender,
    'right_tools': SanrioColors.pastelYellow,
    'around_island': SanrioColors.pastelMint,
    'friendship': SanrioColors.pastelPink,
    'wheatflour': SanrioColors.pastelBlue,
  };

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storage = await StorageService.getInstance();
    _questService = QuestService(storage);
    await _loadQuests();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);
    
    try {
      final quests = await _questService.getAllQuests();
      setState(() {
        _allQuests = quests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleQuestStep(String questId, int stepIndex) async {
    await _questService.toggleQuestStepCompletion(questId, stepIndex);
    await _loadQuests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelMint,
        elevation: 0,
        title: Text(
          'Quest Tracker',
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
              onRefresh: _loadQuests,
              color: SanrioColors.brightPink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 84),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallProgress(),
                    const SizedBox(height: 24),
                    ..._categoryNames.keys.map((category) {
                      final quests = _allQuests.where((q) => q.category == category).toList();
                      if (quests.isEmpty) return const SizedBox.shrink();
                      
                      return Column(
                        children: [
                          _buildQuestCategory(category, quests),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallProgress() {
    final completedQuests = _allQuests.where((q) => q.isCompleted).length;
    final totalQuests = _allQuests.length;
    final progress = totalQuests > 0 ? completedQuests / totalQuests : 0.0;

    return KawaiiCard(
      backgroundColor: SanrioColors.pastelPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⭐', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Overall Quest Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: SanrioColors.pastelBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: MediaQuery.of(context).size.width * progress,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [SanrioColors.brightPink, SanrioColors.softPink],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedQuests of $totalQuests quests completed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SanrioColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCategory(String category, List<Quest> quests) {
    final categoryName = _categoryNames[category] ?? category;
    final categoryEmoji = _categoryEmojis[category] ?? '📋';
    final categoryColor = _categoryColors[category] ?? SanrioColors.pastelBlue;

    return KawaiiCard(
      backgroundColor: categoryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(categoryEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...quests.map((quest) => _buildQuestItem(quest)),
        ],
      ),
    );
  }

  Widget _buildQuestItem(Quest quest) {
    final completedSteps = quest.stepCompletions.where((completed) => completed).length;
    final totalSteps = quest.steps.length;
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                quest.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: quest.isCompleted ? SanrioColors.checklistCompleted : SanrioColors.lightText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quest.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Text(
                '$completedSteps/$totalSteps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SanrioColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: SanrioColors.checklistDefault.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width * progress,
                  height: 6,
                  decoration: BoxDecoration(
                    color: quest.isCompleted 
                        ? SanrioColors.checklistCompleted 
                        : SanrioColors.brightPink,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...quest.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = quest.stepCompletions[index];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: KawaiiCheckbox(
                value: isCompleted,
                text: step,
                onChanged: (_) => _toggleQuestStep(quest.id, index),
              ),
            );
          }),
        ],
      ),
    );
  }
}