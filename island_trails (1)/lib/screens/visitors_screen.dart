import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/models/visitor.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/visitor_service.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  late VisitorService _visitorService;
  List<Visitor> _visitors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final storage = await StorageService.getInstance();
    _visitorService = VisitorService(storage);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _visitorService.getAllVisitors();
      setState(() {
        _visitors = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelPink,
        elevation: 0,
        title: Text('Visitors', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SanrioColors.brightPink))
          : RefreshIndicator(
              onRefresh: _load,
              color: SanrioColors.brightPink,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 84),
                itemCount: _visitors.length,
                itemBuilder: (context, index) => _buildVisitorCard(_visitors[index]),
              ),
            ),
    );
  }

  Widget _buildVisitorCard(Visitor v) {
    return KawaiiCard(
      backgroundColor: SanrioColors.pastelBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SanrioColors.pastelPink,
                child: Text('🧳', style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(v.name, style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          KawaiiCheckbox(
            value: v.isUnlocked,
            text: 'Unlocked',
            onChanged: (val) => _setUnlocked(v, val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('⭐', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(child: _buildStarRow(v)),
              Text('${v.starLevel}/5', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SanrioColors.lightText)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('🏠', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  v.house.isEmpty ? 'Set house' : v.house,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Edit house',
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _editHouse(v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Requirements', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Column(
            children: List.generate(v.requirements.length, (i) {
              final req = v.requirements[i];
              final comps = v.requirementCompletions;
              final done = i < comps.length ? comps[i] : false;
              return KawaiiCheckbox(
                value: done,
                text: req,
                onChanged: (_) => _toggleRequirement(v, i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(Visitor v) {
    return Row(
      children: List.generate(5, (i) {
        final filled = (i + 1) <= v.starLevel;
        return GestureDetector(
          onTap: () => _setStars(v, i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 24,
            ),
          ),
        );
      }),
    );
  }

  Future<void> _setStars(Visitor v, int stars) async {
    await _visitorService.updateStarLevel(v.id, stars);
    await _load();
  }

  Future<void> _toggleRequirement(Visitor v, int index) async {
    await _visitorService.toggleRequirement(v.id, index);
    await _load();
  }

  Future<void> _setUnlocked(Visitor v, bool value) async {
    await _visitorService.setUnlocked(v.id, value);
    await _load();
  }

  Future<void> _editHouse(Visitor v) async {
    final controller = TextEditingController(text: v.house);
    final newHouse = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SanrioColors.surface,
          title: Text('Edit House', style: Theme.of(context).textTheme.titleMedium),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g. Seaside Cottage'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: SanrioColors.brightPink, foregroundColor: Colors.white),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newHouse != null) {
      await _visitorService.updateHouse(v.id, newHouse);
      await _load();
    }
  }
}
