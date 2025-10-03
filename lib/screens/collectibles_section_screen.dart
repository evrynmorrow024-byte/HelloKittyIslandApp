import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/collectible_service.dart';
import 'package:island_trails/models/collectible_hub.dart';
import 'package:island_trails/screens/collectibles_checklist_screen.dart';

class CollectiblesSectionScreen extends StatefulWidget {
  final CollectibleSection section;
  const CollectiblesSectionScreen({super.key, required this.section});

  @override
  State<CollectiblesSectionScreen> createState() => _CollectiblesSectionScreenState();
}

class _CollectiblesSectionScreenState extends State<CollectiblesSectionScreen> {
  late CollectibleService _service;
  late CollectibleSection _section;
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
    setState(() {
      _section = sec;
      _loading = false;
    });
  }

  Future<void> _addSubsection() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SanrioColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Subsection', style: Theme.of(ctx).textTheme.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter subsection title'),
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

    if (title != null && title.isNotEmpty) {
      await _service.addSubsection(_section.id, title);
      await _reload();
    }
  }

  void _openChecklist({CollectibleSubsection? sub}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectiblesChecklistScreen(section: _section, subsection: sub),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 84;

    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelBlue,
        elevation: 0,
        title: Text(_section.title, style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        actions: [
          if (_section.hasSubsections)
            IconButton(
              onPressed: _addSubsection,
              icon: const Icon(Icons.add_circle, color: SanrioColors.brightPink),
              tooltip: 'Add Subsection',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_section.hasSubsections)
                      KawaiiCard(
                        backgroundColor: SanrioColors.pastelBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('📦', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('Items', style: Theme.of(context).textTheme.titleMedium)),
                                TextButton.icon(
                                  onPressed: () => _openChecklist(),
                                  icon: const Icon(Icons.navigate_next, color: SanrioColors.brightPink),
                                  label: const Text('Open', style: TextStyle(color: SanrioColors.brightPink)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('This section has a single checklist. Tap Open to view or add items.', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      )
                    else
                      ..._section.subsections.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _openChecklist(sub: s),
                              child: KawaiiCard(
                                backgroundColor: SanrioColors.pastelBlue,
                                child: Row(
                                  children: [
                                    const Text('📂', style: TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        s.title,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ),
                                    const Icon(Icons.navigate_next, color: SanrioColors.brightPink),
                                  ],
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
      floatingActionButton: !_section.hasSubsections
          ? FloatingActionButton.extended(
              onPressed: () => _openChecklist(),
              backgroundColor: SanrioColors.brightPink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            )
          : FloatingActionButton.extended(
              onPressed: _addSubsection,
              backgroundColor: SanrioColors.brightPink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Subsection'),
            ),
    );
  }
}
