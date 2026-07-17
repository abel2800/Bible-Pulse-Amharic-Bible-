import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/community_provider.dart';
import '../../services/auth_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final _controller = TextEditingController();
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final user = context.read<AuthService>().currentUser;
    if (user != null) context.read<CommunityProvider>().watch(user.uid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final community = context.watch<CommunityProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: user == null
          ? const Center(child: Text('Sign in to access the community.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    maxLength: 2000,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Share an encouragement',
                      suffixIcon: IconButton(
                        tooltip: 'Post',
                        onPressed: () async {
                          await community.create(user.uid, _controller.text);
                          _controller.clear();
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ),
                  ),
                ),
                if (community.loading) const LinearProgressIndicator(),
                if (community.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(community.error!),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: community.posts.length,
                    itemBuilder: (context, index) {
                      final post = community.posts[index];
                      return ListTile(
                        minTileHeight: 64,
                        title: Text(post.body),
                        subtitle: Text(post.createdAt.toLocal().toString()),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Post actions',
                          onSelected: (action) async {
                            if (action == 'report') {
                              await community.report(
                                user.uid,
                                post.id,
                                'user_report',
                              );
                            } else if (action == 'block') {
                              await community.block(user.uid, post.authorId);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'report',
                              child: Text('Report'),
                            ),
                            PopupMenuItem(
                              value: 'block',
                              child: Text('Block author'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
