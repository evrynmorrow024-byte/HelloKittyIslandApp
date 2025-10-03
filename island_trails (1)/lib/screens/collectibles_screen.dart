import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';
import 'package:island_trails/widgets/kawaii_card.dart';
import 'package:island_trails/services/storage_service.dart';
import 'package:island_trails/services/collectible_service.dart';
import 'package:island_trails/models/collectible_hub.dart';
import 'package:island_trails/screens/collectibles_section_screen.dart';
import 'package:island_trails/screens/collectibles_checklist_screen.dart';

class CollectiblesScreen extends StatefulWidget {
  const CollectiblesScreen({super.key});

  @override
  State<CollectiblesScreen> createState() => _CollectiblesScreenState();
}

class _CollectiblesScreenState extends State<CollectiblesScreen> {
  late CollectibleService _service;
  List<CollectibleSection> _sections = [];
  bool _loading = true;
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final storage = await StorageService.getInstance();
    _service = CollectibleService(storage);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final secs = await _service.getSections();
    setState(() {
      _sections = secs;
      _keys
        ..clear()
        ..addEntries(secs.map((s) => MapEntry(s.id, GlobalKey())));
      _loading = false;
    });
  }

  Future<void> _addSection() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SanrioColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Section', style: Theme.of(ctx).textTheme.titleMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter section title'),
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
      await _service.addSection(title);
      await _load();
    }
  }

  void _open(CollectibleSection s) {
    if (s.hasSubsections) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CollectiblesSectionScreen(section: s)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CollectiblesChecklistScreen(section: s)));
    }
  }

  void _jumpTo(String sectionId) {
    final key = _keys[sectionId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 84;

    return Scaffold(
      backgroundColor: SanrioColors.surface,
      appBar: AppBar(
        backgroundColor: SanrioColors.pastelBlue,
        elevation: 0,
        title: Text('Collectibles', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addSection,
            icon: const Icon(Icons.add_circle, color: SanrioColors.brightPink),
            tooltip: 'Add Section',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SanrioColors.brightPink))
          : RefreshIndicator(
              onRefresh: _load,
              color: SanrioColors.brightPink,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeaderJumpBar()),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final s = _sections[i];
                          return Container(
                            key: _keys[s.id],
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _open(s),
                              child: KawaiiCard(
                                backgroundColor: SanrioColors.pastelBlue,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: SanrioColors.pastelPink,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(child: Icon(s.icon ?? Icons.folder, color: SanrioColors.brightPink)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 4),
                                          Text(
                                            s.hasSubsections ? '${s.subsections.length} subsections' : 'Checklist',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SanrioColors.lightText),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.navigate_next, color: SanrioColors.brightPink),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _sections.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSection,
        backgroundColor: SanrioColors.brightPink,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Section'),
      ),
    );
  }

  Widget _buildHeaderJumpBar() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) {
          final s = _sections[i];
          return GestureDetector(
            onTap: () => _jumpTo(s.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SanrioColors.pastelPink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: SanrioColors.lightShadow.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Icon(s.icon ?? Icons.folder, size: 18, color: SanrioColors.brightPink),
                  const SizedBox(width: 6),
                  Text(s.title, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _sections.length,
      ),
    );
  }
}
