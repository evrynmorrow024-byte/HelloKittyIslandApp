import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/widgets/progress_bar.dart';
import 'package:island_trails/models/character.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/character_service.dart';

class CharacterDetailScreen extends StatefulWidget {
  final String characterId;
  final VoidCallback? onUpdate;

  const CharacterDetailScreen({
    super.key,
    required this.characterId,
    this.onUpdate,
  });

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late CharacterService _characterService;
  Character? _character;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storage = await StorageService.getInstance();
    _characterService = CharacterService(storage);
    await _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    setState(() => _isLoading = true);
    
    try {
      final character = await _characterService.getCharacterById(widget.characterId);
      setState(() {
        _character = character;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleRequirement(int levelIndex, int requirementIndex) async {
    if (_character != null) {
      await _characterService.toggleFriendshipRequirement(
        _character!.id,
        levelIndex,
        requirementIndex,
      );
      await _loadCharacter();
      widget.onUpdate?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: SanrioColors.surface,
        appBar: AppBar(
          backgroundColor: SanrioColors.pastelPink,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: SanrioColors.brightPink,
          ),
        ),
      );
    }

    if (_character == null) {
      return Scaffold(
        backgroundColor: SanrioColors.surface,
        appBar: AppBar(
          backgroundColor: SanrioColors.pastelPink,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Character not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelPink,
        elevation: 0,
        title: Text(
          _character!.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCharacterInfo(),
            const SizedBox(height: 24),
            _buildFriendshipLevels(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterInfo() {
    return KawaiiCard(
      backgroundColor: SanrioColors.pastelPink,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.network(
              _character!.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: SanrioColors.pastelMint,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: Text('🎀', style: TextStyle(fontSize: 48)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _character!.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          KawaiiCheckbox(
            value: _character!.isUnlocked,
            text: 'Unlocked',
            onChanged: (v) async {
              await _characterService.setUnlocked(_character!.id, v);
              await _loadCharacter();
              widget.onUpdate?.call();
            },
          ),
          const SizedBox(height: 16),
          _buildInfoRow('🎂', 'Birthday', _character!.birthday),
          const SizedBox(height: 8),
          _buildInfoRow('🎁', 'Favorite Gift', _character!.favoriteGift),
          const SizedBox(height: 8),
          _buildInfoRow('👥', 'Friends', _character!.relationships.join(', ')),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Level: ${_character!.currentFriendshipLevel}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SanrioColors.brightPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendshipLevels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Friendship Levels',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ..._character!.friendshipLevels.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;
          final isCurrentLevel = _character!.currentFriendshipLevel == level.level;
          final isCompleted = _character!.currentFriendshipLevel > level.level;
          
          return _buildFriendshipLevel(level, index, isCurrentLevel, isCompleted);
        }),
      ],
    );
  }

  Widget _buildFriendshipLevel(FriendshipLevel level, int levelIndex, bool isCurrentLevel, bool isCompleted) {
    final completedRequirements = level.requirementCompletions.where((completed) => completed).length;
    final totalRequirements = level.requirements.length;
    final progress = totalRequirements > 0 ? completedRequirements / totalRequirements : 0.0;
    
    Color backgroundColor;
    if (isCompleted) {
      backgroundColor = SanrioColors.pastelMint;
    } else if (isCurrentLevel) {
      backgroundColor = SanrioColors.pastelYellow;
    } else {
      backgroundColor = SanrioColors.pastelBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: KawaiiCard(
        backgroundColor: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted 
                      ? Icons.check_circle 
                      : isCurrentLevel 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_unchecked,
                  color: isCompleted 
                      ? SanrioColors.checklistCompleted 
                      : isCurrentLevel 
                          ? SanrioColors.brightPink 
                          : SanrioColors.lightText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Level ${level.level}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (isCurrentLevel)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SanrioColors.brightPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Current',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reward: ${level.reward}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: SanrioColors.brightPink,
              ),
            ),
            const SizedBox(height: 12),
            KawaiiProgressBar(progress: progress, height: 6, backgroundColor: SanrioColors.checklistDefault.withValues(alpha: 0.3), progressColor: SanrioColors.brightPink),
            const SizedBox(height: 8),
            Text(
              'Progress: $completedRequirements/$totalRequirements',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SanrioColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Requirements:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...level.requirements.asMap().entries.map((entry) {
              final reqIndex = entry.key;
              final requirement = entry.value;
              final isCompleted = level.requirementCompletions[reqIndex];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: KawaiiCheckbox(
                  value: isCompleted,
                  text: requirement,
                  onChanged: (_) => _toggleRequirement(levelIndex, reqIndex),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}