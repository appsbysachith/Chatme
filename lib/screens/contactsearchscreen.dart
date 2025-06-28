import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:five/functions/showchatoption.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactSearchScreen extends ConsumerStatefulWidget {
  const ContactSearchScreen({super.key});

  @override
  ConsumerState<ContactSearchScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<ContactSearchScreen> {
  List<Map<String, dynamic>> _allContacts = [];
  List<Map<String, dynamic>> _filterContacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getContacts() async {
    final currentUser = ref.read(userProvider);
    final currentUserId = currentUser?.uid ?? '';
    try {
      final querysnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('contacts')
              .get();

      final contacts = querysnapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        _allContacts = contacts;
        _filterContacts = contacts; // Initialize filtered list
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filterContacts =
          _allContacts.where((contact) {
            final firstname = (contact['firstname'] ?? '').toLowerCase();
            final lastname = (contact['lastname'] ?? '').toLowerCase();
            return firstname.contains(query) || lastname.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 58),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: const Color(0xFFF3F6F6),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Text(
              'People',
              style: TextStyle(
                fontFamily: 'Caros',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Expanded(
              child:
                  _filterContacts.isEmpty
                      ? const Center(child: Text('No contacts found'))
                      : ListView.builder(
                        itemCount: _filterContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filterContacts[index];
                          final name =
                              "${contact['firstname'] ?? ''} ${contact['lastname'] ?? ''}";
                          final email = contact['email'] ?? 'no email';

                          return ListTile(
                            onTap:
                                () => showChatoption(context, contact['uid']),
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
                            title: Text(name),
                            subtitle: Text(email),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
