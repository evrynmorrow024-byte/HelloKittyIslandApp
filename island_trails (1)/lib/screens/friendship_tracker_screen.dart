import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/models/character.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/character_service.dart';
import 'package:island_trails/screens/character_detail_screen.dart';
import 'package:island_trails/widgets/progress_bar.dart';

class FriendshipTrackerScreen extends StatefulWidget {
  const FriendshipTrackerScreen({super.key});

  @override
  State<FriendshipTrackerScreen> createState() => _FriendshipTrackerScreenState();
}

class _FriendshipTrackerScreenState extends State<FriendshipTrackerScreen> {
  late CharacterService _characterService;
  List<Character> _characters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storage = await StorageService.getInstance();
    _characterService = CharacterService(storage);
    await _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);
    
    try {
      final characters = await _characterService.getAllCharacters();
      setState(() {
        _characters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setCharacterUnlocked(Character c, bool value) async {
    await _characterService.setUnlocked(c.id, value);
    await _loadCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelPink,
        elevation: 0,
        title: Text(
          'Friendship Tracker',
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
              onRefresh: _loadCharacters,
              color: SanrioColors.brightPink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 84),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFriendshipOverview(),
                    const SizedBox(height: 24),
                    Text(
                      'Your Friends',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: _characters.length,
                      itemBuilder: (context, index) {
                        return _buildCharacterCard(_characters[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFriendshipOverview() {
    final totalFriendshipLevel = _characters.fold<int>(0, (sum, char) => sum + char.currentFriendshipLevel);
    final maxPossibleLevel = _characters.length * 3; // Assuming 3 max levels per character
    final progress = maxPossibleLevel > 0 ? totalFriendshipLevel / maxPossibleLevel : 0.0;

    return KawaiiCard(
      backgroundColor: SanrioColors.pastelMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('💕', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Friendship Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          KawaiiProgressBar(progress: progress, height: 20),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Friendship Level: $totalFriendshipLevel',
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

  Widget _buildCharacterCard(Character character) {
    final maxLevel = character.friendshipLevels.length;
    final currentLevel = character.currentFriendshipLevel;
    final progress = maxLevel > 0 ? currentLevel / maxLevel : 0.0;

    return KawaiiCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CharacterDetailScreen(
              characterId: character.id,
              onUpdate: _loadCharacters,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              character.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SanrioColors.pastelPink,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Center(
                  child: Text('🎀', style: TextStyle(fontSize: 32)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            character.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          KawaiiCheckbox(
            value: character.isUnlocked,
            text: 'Unlocked',
            onChanged: (val) => _setCharacterUnlocked(character, val),
          ),
          const SizedBox(height: 8),
          Text(
            'Level $currentLevel/$maxLevel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SanrioColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * progress;
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: SanrioColors.pastelBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: barWidth,
                    height: 8,
                    decoration: BoxDecoration(
                      color: SanrioColors.brightPink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '🎂 ${character.birthday}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SanrioColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}