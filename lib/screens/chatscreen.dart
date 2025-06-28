import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverid;
  const ChatScreen({super.key, required this.receiverid});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _message = TextEditingController();
  late String currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    currentUser = user?.uid ?? '';
    checkContact();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void checkContact() async {
    final contactSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser)
            .collection('contacts')
            .doc(widget.receiverid)
            .get();

    final contactExists = contactSnapshot.exists;

    if (mounted) {
      setState(() {
        userData = contactSnapshot.data();
      });
    }

    if (!contactExists && mounted) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder:
            (_) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This user is not in your contact list. Do you wish to add the user?',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser)
                          .collection('contacts')
                          .doc(widget.receiverid)
                          .set({'addedAt': Timestamp.now()});
                      context.pop();
                    },
                    child: const Text('ADD'),
                  ),
                  ElevatedButton(onPressed: () {}, child: const Text('BLOCK')),
                ],
              ),
            ),
      );
    }
  }

  void sendMessage() async {
    final chatIdSort = [currentUser, widget.receiverid]..sort();
    final chatId = chatIdSort.join('_');
    final message = _message.text.trim();
    if (message.isEmpty) return;

    final lastMessage = {
      'message': message,
      'time': Timestamp.now(),
      'senderID': currentUser,
    };

    try {
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [currentUser, widget.receiverid],
        'lastMessage': lastMessage,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(lastMessage);

      _message.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Stream<QuerySnapshot> getMessages() {
    final chatIdSort = [currentUser, widget.receiverid]..sort();
    final chatId = chatIdSort.join('_');
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              userData != null && userData!['profileImage'] != null
                  ? CircleAvatar(
                    backgroundImage: NetworkImage(userData!['profileImage']),
                  )
                  : const CircleAvatar(child: Icon(Icons.person)),
        ),
        title: Text(userData?['username'] ?? widget.receiverid),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: StreamBuilder(
                stream: getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error retrieving the chats'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      final message = data['message'];
                      final senderID = data['senderID'];
                      final isCurrentUser = senderID == currentUser;

                      return Align(
                        alignment:
                            isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isCurrentUser
                                    ? Colors.green
                                    : Colors.lightGreen[100],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isCurrentUser ? 16 : 0),
                              topRight: Radius.circular(isCurrentUser ? 0 : 16),
                              bottomLeft: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.lightBlue[50],
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _message,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      fillColor: Colors.lightBlue[50],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
