import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/screens/data_import_screen.dart';
import 'package:island_trails/widgets/progress_bar.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/quest_service.dart';
import 'package:island_trails/services/daily_task_service.dart';
import 'package:island_trails/services/collectible_service.dart';
import 'package:island_trails/services/character_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StorageService _storage;
  late QuestService _questService;
  late DailyTaskService _dailyTaskService;
  late CollectibleService _collectibleService;
  late CharacterService _characterService;

  double _overallProgress = 0.0;
  double _friendshipProgress = 0.0;
  double _collectiblesProgress = 0.0;
  double _questsProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _storage = await StorageService.getInstance();
    _questService = QuestService(_storage);
    _dailyTaskService = DailyTaskService(_storage);
    _collectibleService = CollectibleService(_storage);
    _characterService = CharacterService(_storage);
    
    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    // Calculate quest progress
    final quests = await _questService.getAllQuests();
    final completedQuests = quests.where((q) => q.isCompleted).length;
    final questProgress = quests.isNotEmpty ? completedQuests / quests.length : 0.0;

    // Calculate collectibles progress
    final collectiblesProgress = (await _collectibleService.getCollectionProgress()) / 100.0;

    // Calculate friendship progress (average current level / max level)
    final characters = await _characterService.getAllCharacters();
    final totalLevels = characters.fold<int>(0, (sum, char) => sum + char.currentFriendshipLevel);
    final maxPossibleLevels = characters.length * 3; // Assuming 3 max levels per character
    final friendshipProgress = maxPossibleLevels > 0 ? totalLevels / maxPossibleLevels : 0.0;

    // Calculate overall progress
    final overall = (questProgress + collectiblesProgress + friendshipProgress) / 3;

    setState(() {
      _questsProgress = questProgress;
      _collectiblesProgress = collectiblesProgress;
      _friendshipProgress = friendshipProgress;
      _overallProgress = overall;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: SanrioColors.brightPink,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 84),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildOverallProgress(),
                const SizedBox(height: 24),
                _buildSectionProgress(),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 24),
                _buildWelcomeMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: SanrioColors.pastelPink,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: SanrioColors.lightShadow.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌸', style: TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello Kitty Island',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Adventure Tracker',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SanrioColors.lightText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Import Data',
          icon: const Icon(Icons.file_upload_outlined, color: Colors.blueAccent),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DataImportScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOverallProgress() {
    return KawaiiCard(
      backgroundColor: SanrioColors.pastelPink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Completion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          KawaiiProgressBar(
            progress: _overallProgress,
            label: 'Overall Progress',
            height: 24,
          ),
          const SizedBox(height: 12),
          Text(
            'Keep going! You\'re doing amazing! 🌟',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SanrioColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress by Section',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        KawaiiCard(
          backgroundColor: SanrioColors.pastelMint,
          child: Column(
            children: [
              KawaiiProgressBar(
                progress: _friendshipProgress,
                label: 'Friendship 💕',
                progressColor: SanrioColors.brightPink,
                height: 18,
              ),
              const SizedBox(height: 16),
              KawaiiProgressBar(
                progress: _collectiblesProgress,
                label: 'Collectibles 🎁',
                progressColor: SanrioColors.babyBlue,
                height: 18,
              ),
              const SizedBox(height: 16),
              KawaiiProgressBar(
                progress: _questsProgress,
                label: 'Quests ⭐',
                progressColor: SanrioColors.mintGreen,
                height: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KawaiiCard(
                backgroundColor: SanrioColors.pastelYellow,
                child: Column(
                  children: [
                    Text(
                      '🎂',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '5',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Friends',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: KawaiiCard(
                backgroundColor: SanrioColors.pastelBlue,
                child: Column(
                  children: [
                    Text(
                      '🎁',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '20',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: KawaiiCard(
                backgroundColor: SanrioColors.pastelLavender,
                child: Column(
                  children: [
                    Text(
                      '⭐',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '5',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Quests',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return KawaiiCard(
      backgroundColor: SanrioColors.pastelMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  'https://pixabay.com/get/g5276a9e7c7a38cea20ce8112040b0f4ccaada7ef4744b98429dd0ca525ab20f6cf2f2aaea18d3a3fa4055b0c6d90e235a684f6a01124648a72de54f0c43a63e5_1280.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: SanrioColors.pastelPink,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(child: Text('🎀', style: TextStyle(fontSize: 24))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome to your magical island adventure! 🌺',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explore, make friends, and collect wonderful memories in this kawaii paradise. Every day brings new adventures with Hello Kitty and friends!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SanrioColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}