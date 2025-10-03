import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/widgets/kawaii_checkbox.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/collectible_service.dart';
import 'package:island_trails/models/collectible_hub.dart';

class CollectiblesChecklistScreen extends StatefulWidget {
  final CollectibleSection section;
  final CollectibleSubsection? subsection;

  const CollectiblesChecklistScreen({super.key, required this.section, this.subsection});

  @override
  State<CollectiblesChecklistScreen> createState() => _CollectiblesChecklistScreenState();
}

class _CollectiblesChecklistScreenState extends State<CollectiblesChecklistScreen> {
  late CollectibleService _service;
  late CollectibleSection _section;
  CollectibleSubsection? _subsection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final storage = await StorageService.getInstance();
    _service = CollectibleService(storage);
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final sections = await _service.getSections();
    final sec = sections.firstWhere((s) => s.id == widget.section.id);
    CollectibleSubsection? sub;
    if (widget.subsection != null) {
      sub = sec.subsections.firstWhere((x) => x.id == widget.subsection!.id);
    }
    setState(() {
      _section = sec;
      _subsection = sub;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SanrioColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Item', style: Theme.of(ctx).textTheme.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter item name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: SanrioColors.brightPink, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await _service.addItem(
        sectionId: _section.id,
        subsectionId: _subsection?.id,
        name: name,
      );
      await _reload();
    }
  }

  Future<void> _toggle(String itemId) async {
    await _service.toggleItem(sectionId: _section.id, subsectionId: _subsection?.id, itemId: itemId);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 84;

    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelBlue,
        elevation: 0,
        title: Text(
          _subsection?.title ?? _section.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add_circle, color: SanrioColors.brightPink),
            tooltip: 'Add Item',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SanrioColors.brightPink))
          : RefreshIndicator(
              onRefresh: _reload,
              color: SanrioColors.brightPink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
                child: KawaiiCard(
                  backgroundColor: SanrioColors.pastelBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Checklist',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, color: SanrioColors.brightPink),
                            label: const Text('Add', style: TextStyle(color: SanrioColors.brightPink)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (ctx) {
                          final items = _subsection?.items ?? _section.items;
                          if (items.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'No items yet. Tap Add to create one.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SanrioColors.lightText),
                              ),
                            );
                          }
                          return Column(
                            children: items.map((i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: KawaiiCheckbox(
                                value: i.isCollected,
                                text: i.name,
                                onChanged: (_) => _toggle(i.id),
                              ),
                            )).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
