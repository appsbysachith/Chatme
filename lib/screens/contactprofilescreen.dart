import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  return user?.uid;
});

class ContactProfileScreen extends ConsumerStatefulWidget {
  const ContactProfileScreen({super.key});

  @override
  ConsumerState<ContactProfileScreen> createState() =>
      _ContactProfileScreenState();
}

class _ContactProfileScreenState extends ConsumerState<ContactProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> pickAndUploadImage() async {
    final currentUserId = ref.read(currentUserIdProvider);

    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) return;
    final file = File(pickedImage.path);

    try {
      final cloudName = 'di6fs43mv';
      final uploadPreset = 'chatme';
      final uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request =
          http.MultipartRequest("POST", uploadUrl)
            ..fields['upload_preset'] = uploadPreset
            ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = jsonDecode(responseData);
      final imageUrl = result['secure_url'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'profileImage': imageUrl});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile picture updated')));
        setState(() {
          userData!['profileImage'] = imageUrl;
        });
      }
    } catch (e) {
      print('Error uploading the image');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading the image')));
    }
  }

  Future<void> getUserData() async {
    final currentUserId = ref.read(currentUserIdProvider);
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();

    if (mounted) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          userData == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Container(
                    height: 293,
                    color: Color(0xFF000E08),
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        userData!['profileImage'] != null
                            ? CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                userData!['profileImage'],
                              ),
                            )
                            : Icon(Icons.person, color: Colors.amber, size: 60),
                        SizedBox(height: 10),
                        Text(
                          '${userData!['name'] ?? 'NO NAME'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Caros',
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${userData!['username'] ?? "NO USERNAME"}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'CircularStd',
                            fontSize: 12,
                            color: Color(0xFF797C7B),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xFF051D13),
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    context.go('/');
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 19,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username',
                            style: TextStyle(
                              fontFamily: 'CircularStd',
                              fontSize: 14,
                              color: Color(0xFF797C7B),
                            ),
                          ),
                          Text(
                            '${userData!['username'] ?? 'NO USERNAME'}',
                            style: TextStyle(
                              fontFamily: 'Caros',
                              fontSize: 18,
                              color: Color(0xFF000E08),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Email Address",
                            style: TextStyle(
                              fontFamily: 'CircularStd',
                              fontSize: 14,
                              color: Color(0xFF797C7B),
                            ),
                          ),
                          Text(
                            '${userData!['email'] ?? 'NO EMAIL'}',
                            style: TextStyle(
                              fontFamily: 'Caros',
                              fontSize: 18,
                              color: Color(0xFF000E08),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: pickAndUploadImage,
                            child: Text('UPLOAD PROFILE PICTURE'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
