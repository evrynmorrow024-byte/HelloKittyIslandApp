import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:island_trails/models/character.dart';
import 'package:island_trails/models/quest.dart';
import 'package:island_trails/models/collectible.dart';
import 'package:island_trails/models/daily_task.dart';
import 'package:island_trails/models/visitor.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/theme.dart';

class DataImportScreen extends StatefulWidget {
  const DataImportScreen({super.key});

  @override
  State<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends State<DataImportScreen> {
  final TextEditingController _controller = TextEditingController(text: _sampleJson);
  bool _isValid = false;
  String _status = '';
  Color _statusColor = Colors.transparent;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.surface,
        elevation: 0,
        title: Text('Data Import', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            tooltip: 'Paste sample',
            icon: const Icon(Icons.content_paste),
            onPressed: () => setState(() {
              _controller.text = _sampleJson;
              _isValid = false;
              _status = '';
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SanrioColors.pastelBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Paste JSON with keys: characters, quests, collectibles, daily_tasks, visitors. '
                  'Missing created_at/updated_at will be auto-filled. Missing user_id for quests/collectibles/daily_tasks/visitors will default to "user_1".',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: SanrioColors.lightShadow.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '{\n  "characters": [ ... ],\n  "quests": [ ... ],\n  "collectibles": [ ... ],\n  "daily_tasks": [ ... ],\n  "visitors": [ ... ]\n}',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onChanged: (_) => setState(() => _isValid = false),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_status.isNotEmpty)
                Text(_status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _statusColor)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : _validate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SanrioColors.babyBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Validate JSON'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isImporting || !_isValid ? null : _import,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SanrioColors.mintGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isImporting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Import Data'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validate() {
    try {
      final parsed = jsonDecode(_controller.text);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('Root must be a JSON object.');
      }
      // Attempt to sanitize and map to domain objects for validation
      _sanitizeAll(parsed);
      setState(() {
        _isValid = true;
        _status = 'Looks good! You can import now.';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _isValid = false;
        _status = 'Invalid JSON: $e';
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _import() async {
    setState(() {
      _isImporting = true;
      _status = '';
    });
    try {
      final parsed = jsonDecode(_controller.text) as Map<String, dynamic>;
      final sanitized = _sanitizeAll(parsed);

      final storage = await StorageService.getInstance();

      final List<Map<String, dynamic>> charactersJson = (sanitized['characters'] as List<dynamic>).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> questsJson = (sanitized['quests'] as List<dynamic>).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> collectiblesJson = (sanitized['collectibles'] as List<dynamic>).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> tasksJson = (sanitized['daily_tasks'] as List<dynamic>).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> visitorsJson = (sanitized['visitors'] as List<dynamic>).cast<Map<String, dynamic>>();

      await storage.setJsonList('characters', charactersJson);
      await storage.setJsonList('quests', questsJson);
      await storage.setJsonList('collectibles', collectiblesJson);
      await storage.setJsonList('daily_tasks', tasksJson);
      await storage.setJsonList('visitors', visitorsJson);

      if (mounted) {
        setState(() {
          _status = 'Imported successfully! You can navigate back and see the updated data.';
          _statusColor = Colors.green;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Import failed: $e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Map<String, dynamic> _sanitizeAll(Map<String, dynamic> root) {
    final nowIso = DateTime.now().toIso8601String();
    final userIdDefault = 'user_1';

    List<Map<String, dynamic>> sanitizeCharacters() {
      final list = (root['characters'] as List? ?? <dynamic>[]);
      return list.map<Map<String, dynamic>>((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['id'] = (m['id'] ?? _slug(m['name'] ?? 'character')) as String;
        m['image_url'] = m['image_url'] ?? '';
        m['birthday'] = m['birthday'] ?? '';
        m['favorite_gift'] = m['favorite_gift'] ?? '';
        m['relationships'] = (m['relationships'] as List?)?.cast<String>() ?? <String>[];

        final levels = (m['friendship_levels'] as List? ?? <dynamic>[]).map<Map<String, dynamic>>((lvl) {
          final l = Map<String, dynamic>.from(lvl as Map);
          l['level'] = (l['level'] ?? 1) as int;
          l['reward'] = l['reward'] ?? '';
          final reqs = (l['requirements'] as List?)?.cast<String>() ?? <String>[];
          List<bool> comps;
          if (l['requirement_completions'] is List) {
            comps = (l['requirement_completions'] as List).map((e) => e == true).toList();
          } else {
            comps = List<bool>.filled(reqs.length, false);
          }
          l['requirements'] = reqs;
          l['requirement_completions'] = comps.length == reqs.length ? comps : List<bool>.filled(reqs.length, false);
          return l;
        }).toList();
        m['friendship_levels'] = levels;
        m['current_friendship_level'] = m['current_friendship_level'] ?? 0;
        m['is_unlocked'] = (m['is_unlocked'] ?? false) == true;
        m['created_at'] = m['created_at'] ?? nowIso;
        m['updated_at'] = m['updated_at'] ?? nowIso;
        // Validate by constructing object
        Character.fromJson(m);
        return m;
      }).toList();
    }

    List<Map<String, dynamic>> sanitizeQuests() {
      final list = (root['quests'] as List? ?? <dynamic>[]);
      return list.map<Map<String, dynamic>>((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['id'] = (m['id'] ?? _slug(m['title'] ?? 'quest')) as String;
        m['user_id'] = m['user_id'] ?? userIdDefault;
        m['title'] = m['title'] ?? '';
        m['category'] = m['category'] ?? 'friendship';
        final steps = (m['steps'] as List?)?.cast<String>() ?? <String>[];
        List<bool> comps;
        if (m['step_completions'] is List) {
          comps = (m['step_completions'] as List).map((e) => e == true).toList();
        } else {
          comps = List<bool>.filled(steps.length, false);
        }
        m['steps'] = steps;
        m['step_completions'] = comps.length == steps.length ? comps : List<bool>.filled(steps.length, false);
        m['is_completed'] = (m['is_completed'] ?? false) == true;
        m['created_at'] = m['created_at'] ?? nowIso;
        m['updated_at'] = m['updated_at'] ?? nowIso;
        Quest.fromJson(m);
        return m;
      }).toList();
    }

    List<Map<String, dynamic>> sanitizeCollectibles() {
      final list = (root['collectibles'] as List? ?? <dynamic>[]);
      return list.map<Map<String, dynamic>>((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['id'] = (m['id'] ?? _slug(m['name'] ?? 'collectible')) as String;
        m['user_id'] = m['user_id'] ?? userIdDefault;
        m['name'] = m['name'] ?? '';
        m['category'] = m['category'] ?? 'recipes';
        m['is_collected'] = (m['is_collected'] ?? false) == true;
        m['description'] = m['description'];
        m['image_url'] = m['image_url'];
        m['created_at'] = m['created_at'] ?? nowIso;
        m['updated_at'] = m['updated_at'] ?? nowIso;
        Collectible.fromJson(m);
        return m;
      }).toList();
    }

    List<Map<String, dynamic>> sanitizeDailyTasks() {
      final list = (root['daily_tasks'] as List? ?? <dynamic>[]);
      return list.map<Map<String, dynamic>>((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['id'] = (m['id'] ?? _slug(m['title'] ?? 'daily_task')) as String;
        m['user_id'] = m['user_id'] ?? userIdDefault;
        m['title'] = m['title'] ?? '';
        m['is_completed'] = (m['is_completed'] ?? false) == true;
        m['category'] = m['category'] ?? 'daily_tasks';
        m['created_at'] = m['created_at'] ?? nowIso;
        m['updated_at'] = m['updated_at'] ?? nowIso;
        DailyTask.fromJson(m);
        return m;
      }).toList();
    }

    List<Map<String, dynamic>> sanitizeVisitors() {
      final list = (root['visitors'] as List? ?? <dynamic>[]);
      return list.map<Map<String, dynamic>>((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        m['id'] = (m['id'] ?? _slug(m['name'] ?? 'visitor')) as String;
        m['user_id'] = m['user_id'] ?? userIdDefault;
        m['name'] = m['name'] ?? '';
        final reqs = (m['requirements'] as List?)?.cast<String>() ?? <String>[];
        List<bool> comps;
        if (m['requirement_completions'] is List) {
          comps = (m['requirement_completions'] as List).map((e) => e == true).toList();
        } else {
          comps = List<bool>.filled(reqs.length, false);
        }
        m['requirements'] = reqs;
        m['requirement_completions'] = comps.length == reqs.length ? comps : List<bool>.filled(reqs.length, false);
        m['star_level'] = (m['star_level'] ?? 0) as int;
        m['house'] = m['house'] ?? '';
        m['image_url'] = m['image_url'];
        m['is_unlocked'] = (m['is_unlocked'] ?? false) == true;
        m['created_at'] = m['created_at'] ?? nowIso;
        m['updated_at'] = m['updated_at'] ?? nowIso;
        Visitor.fromJson(m);
        return m;
      }).toList();
    }

    final chars = sanitizeCharacters();
    final quests = sanitizeQuests();
    final coll = sanitizeCollectibles();
    final tasks = sanitizeDailyTasks();
    final visitors = sanitizeVisitors();

    return <String, dynamic>{
      'characters': chars,
      'quests': quests,
      'collectibles': coll,
      'daily_tasks': tasks,
      'visitors': visitors,
    };
  }

  String _slug(String value) {
    final lower = value.toLowerCase().trim();
    final onlySafe = lower.replaceAll(RegExp(r'[^a-z0-9_\- ]'), '');
    return onlySafe.replaceAll(RegExp(r'\s+'), '_');
  }
}

const String _sampleJson = '''
{
  "characters": [
    {
      "id": "hello_kitty",
      "name": "Hello Kitty",
      "image_url": "",
      "birthday": "November 1",
      "favorite_gift": "Apple pie",
      "relationships": ["My Melody", "Kuromi"],
      "current_friendship_level": 0,
      "friendship_levels": [
        {"level": 1, "reward": "Bow", "requirements": ["Chat", "Give gift"], "requirement_completions": [false, false]},
        {"level": 2, "reward": "Photo", "requirements": ["Do a quest", "Share meal"], "requirement_completions": [false, false]}
      ]
    }
  ],
  "quests": [
    {
      "id": "island_mystery_1",
      "user_id": "user_1",
      "title": "Island Mystery — Part 1",
      "category": "island_mystery",
      "is_completed": false,
      "steps": ["Talk to Hello Kitty", "Go to the cave"],
      "step_completions": [false, false]
    }
  ],
  "collectibles": [
    {"id": "recipe_apple_pie", "user_id": "user_1", "name": "Apple Pie", "category": "recipes", "is_collected": false, "description": "Tasty!"}
  ],
  "daily_tasks": [
    {"id": "water_flowers", "user_id": "user_1", "title": "Water flowers", "is_completed": false, "category": "daily_tasks"}
  ],
  "visitors": [
    {
      "id": "visitor_blossom_bunny",
      "user_id": "user_1",
      "name": "Blossom Bunny",
      "requirements": ["Bring 3 flowers", "Visit photo spot"],
      "requirement_completions": [false, false],
      "star_level": 0,
      "house": "Seaside Cottage"
    }
  ]
}
''';
