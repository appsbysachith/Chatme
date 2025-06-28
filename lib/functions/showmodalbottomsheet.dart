import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

void showAddContactModal(BuildContext context) {
  final emailcontroller = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                child: Column(
                  children: [
                    Text('Email of the user'),
                    TextFormField(controller: emailcontroller),
                    Text('First name'),
                    TextFormField(controller: firstname),
                    Text('Second name'),
                    TextFormField(controller: lastname),
                  ],
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      print('🔍 Add Contact button pressed');

                      final emailtofind = emailcontroller.text.trim();
                      final firstnamesaved = firstname.text.trim();
                      final lastnamesaved = lastname.text.trim();

                      print('📧 Email to find: $emailtofind');
                      print('🧑 First Name: $firstnamesaved');
                      print('🧑 Last Name: $lastnamesaved');

                      final currentuser = FirebaseAuth.instance.currentUser;

                      if (currentuser == null) {
                        print('❌ No user logged in');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not logged in")),
                        );
                        return;
                      }

                      final currentUserUid = currentuser.uid;
                      print('✅ Current User UID: $currentUserUid');

                      try {
                        final querySnapshot =
                            await FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: emailtofind)
                                .limit(1)
                                .get();

                        print(
                          '📦 Query executed. Found docs: ${querySnapshot.docs.length}',
                        );

                        if (querySnapshot.docs.isNotEmpty) {
                          final contactUser = querySnapshot.docs.first;
                          final contactuid = contactUser.id;

                          print('🔎 Found user. Contact UID: $contactuid');

                          if (contactuid == currentUserUid) {
                            print('⚠️ Attempt to add self');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You cant add yourself as a contact',
                                ),
                              ),
                            );
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserUid)
                              .collection('contacts')
                              .doc(contactuid)
                              .set({
                                'firstname': firstnamesaved,
                                'lastname': lastnamesaved,
                                'email': emailtofind,
                                'uid': contactuid,
                                'addedAt': Timestamp.now(),
                              });

                          print('✅ Contact saved successfully to Firestore');
                          Navigator.of(modalContext).pop();
                          print('📤 Modal popped');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Contact added')),
                          );
                        } else {
                          print('❌ No user found with that email');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not found')),
                          );
                        }
                      } catch (e) {
                        print('🔥 Error during add contact: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error adding contact')),
                        );
                      }
                    },

                    child: Text('Add contact'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
