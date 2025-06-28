import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Signupscreen extends ConsumerStatefulWidget {
  const Signupscreen({super.key});

  @override
  ConsumerState<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends ConsumerState<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _usernamecontroller = TextEditingController();
  final _confirmpasswordcontroller = TextEditingController();

  void onsubmitform() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final email = _emailcontroller.text.trim();
        final password = _passwordcontroller.text.trim();
        final username = _usernamecontroller.text.trim();

        print("🔐 Attempting to create user with email: $email");
        final usercredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        print("✅ User created successfully");
        ref.read(userProvider.notifier).state = usercredential.user;

        final uid = usercredential.user?.uid;
        print("🆔 Fetched UID: $uid");

        print("📝 Storing user data in Firestore...");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({
              'uid': uid,
              'email': email,
              'username': username,
              'createdAt': Timestamp.now(),
            })
            .timeout(
              Duration(seconds: 5),
              onTimeout: () {
                throw Exception("⏱️ Firestore write timed out");
              },
            );
        print("✅ User data saved to Firestore");

        if (!mounted) return;
        context.go('/tabscreen');
      } catch (e) {
        print("❌ Caught error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go("/onboarding");
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Signup with email",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Castro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 17),

              Text(
                'Get chatting with friends and family today by signing up for our chat app',
                style: TextStyle(fontSize: 14, color: const Color(0xFF797C7B)),
              ),
              SizedBox(height: 60),

              Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Your Username",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        controller: _usernamecontroller,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Your Email",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        controller: _emailcontroller,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'please enter a email'
                                    : null,
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Your Password",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        obscureText: true,
                        controller: _passwordcontroller,
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Confirm Password",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                        controller: _confirmpasswordcontroller,
                        obscureText: true,
                        validator:
                            (value) =>
                                value != _passwordcontroller.text
                                    ? 'please match with above field'
                                    : null,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 111),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F6F6),
                  fixedSize: Size(327, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onsubmitform,
                child: Text(
                  "Create an account",
                  style: TextStyle(
                    fontFamily: 'Caros',
                    fontSize: 16,
                    color: Color(0xFF797C7B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
