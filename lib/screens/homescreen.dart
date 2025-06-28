import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Homescreen extends ConsumerStatefulWidget {
  const Homescreen({super.key});

  @override
  ConsumerState<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends ConsumerState<Homescreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final currentUid = currentUser?.uid;

    if (currentUid == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          Container(
            color: const Color(0xFF000E08),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(), // empty space
                const Text(
                  'Home',
                  style: TextStyle(
                    fontFamily: 'Caros',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .where('users', arrayContains: currentUid)
                      .orderBy('lastMessage.time', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading chats: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data yet'));
                }

                final chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final data = chatDocs[index].data() as Map<String, dynamic>;
                    final users = List<String>.from(data['users']);
                    final otherUserId = users.firstWhere(
                      (id) => id != currentUid,
                    );

                    final lastMessage = data['lastMessage']['message'] ?? '';
                    final lastTime = data['lastMessage']['time'] as Timestamp?;

                    return ListTile(
                      onTap:
                          () => context.push('/chatscreen', extra: otherUserId),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(otherUserId),
                      subtitle: Text(lastMessage),
                      trailing: Text(
                        lastTime != null
                            ? TimeOfDay.fromDateTime(
                              lastTime.toDate(),
                            ).format(context)
                            : '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: FloatingActionButton(
            backgroundColor: Colors.lightGreen,
            onPressed: () => context.push('/searchcontact'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
