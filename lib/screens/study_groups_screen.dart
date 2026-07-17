import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_group_provider.dart';
import '../services/auth_service.dart';

class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen> {
  bool _watching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_watching) return;
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      context.read<StudyGroupProvider>().watch(user.uid);
      _watching = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final groups = context.watch<StudyGroupProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Private reading groups')),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _create(context, user.uid),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('New group'),
            ),
      body: user == null
          ? const Center(child: Text('Sign in to use private reading groups.'))
          : groups.error != null
              ? Center(child: Text(groups.error!))
              : groups.groups.isEmpty
                  ? const Center(
                      child: Text(
                        'Create a family or church-cell reading group.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      itemCount: groups.groups.length,
                      itemBuilder: (context, index) {
                        final group = groups.groups[index];
                        final day = group.progressByUser[user.uid] ?? 0;
                        return Card(
                          child: ListTile(
                            minTileHeight: 72,
                            leading: const Icon(Icons.groups_rounded),
                            title: Text(group.name),
                            subtitle: Text(
                              '${group.memberIds.length} members · '
                              'Your completed day: $day',
                            ),
                            trailing: IconButton(
                              tooltip: 'Complete next day',
                              onPressed: () => groups.updateProgress(
                                group.id,
                                user.uid,
                                day + 1,
                              ),
                              icon: const Icon(Icons.task_alt_rounded),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Future<void> _create(BuildContext context, String ownerId) async {
    final name = TextEditingController();
    final plan = TextEditingController();
    final members = TextEditingController();
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New reading group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Group name'),
            ),
            TextField(
              controller: plan,
              decoration: const InputDecoration(labelText: 'Reading plan ID'),
            ),
            TextField(
              controller: members,
              decoration: const InputDecoration(
                labelText: 'Member user IDs (comma-separated)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (save == true && context.mounted && name.text.trim().isNotEmpty) {
      await context.read<StudyGroupProvider>().create(
            ownerId: ownerId,
            name: name.text,
            planId: plan.text.trim(),
            invitedUserIds: members.text
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList(),
          );
    }
    name.dispose();
    plan.dispose();
    members.dispose();
  }
}
