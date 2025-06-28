import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:five/functions/showmodalbottomsheet.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Contactscreen extends ConsumerStatefulWidget {
  const Contactscreen({super.key});

  @override
  ConsumerState<Contactscreen> createState() => _ContactscreenState();
}

class _ContactscreenState extends ConsumerState<Contactscreen> {
  Future<List<Map<String, dynamic>>> getContacts(String? currentUserUid) async {
    if (currentUserUid == null || currentUserUid.isEmpty) return [];

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .collection('contacts')
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final currentUserUid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFF000E08),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.push('/searchcontact');
                    },
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
                Text(
                  'Contacts',
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
                    onPressed: () {
                      showAddContactModal(context);
                    },
                    icon: const Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 21, top: 41),
            child: Text(
              "My Contact",
              style: TextStyle(
                fontFamily: 'Caros',
                fontSize: 16,
                color: Color(0xFF000E08),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 21, right: 21, top: 41),
              child: FutureBuilder(
                future: getContacts(currentUserUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('error ${snapshot.error}'));
                  }

                  final contacts = snapshot.data ?? [];

                  if (contacts.isEmpty) {
                    return const Center(child: Text('No contacts found'));
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final name =
                          "${contact['firstname'] ?? ''} ${contact['lastname'] ?? ''}";
                      final email = contact['email'] ?? 'No email';

                      return ListTile(
                        leading:
                            contact['profileImage'] != null
                                ? CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    contact['profileImage'],
                                  ),
                                )
                                : const CircleAvatar(
                                  radius: 25,
                                  child: Icon(Icons.person),
                                ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Caros',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000E08),
                          ),
                        ),
                        subtitle: Text(
                          email,
                          style: TextStyle(
                            fontFamily: 'CircularStd',
                            fontSize: 12,
                            color: Color(0xFF797C7B),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
