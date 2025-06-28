import 'package:firebase_auth/firebase_auth.dart';
import 'package:five/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Loginscreen extends ConsumerStatefulWidget {
  const Loginscreen({super.key});

  @override
  ConsumerState<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends ConsumerState<Loginscreen> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  Future<void> _onpress() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailcontroller.text,
            password: _passwordcontroller.text,
          );

      final user = userCredential.user;
      ref.read(userProvider.notifier).state = user;

      if (!mounted) return;

      if (user != null && mounted) {
        context.go('/tabscreen');
        print(FirebaseAuth.instance.currentUser?.uid);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error found ${e.toString()}')));
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
                "Login in to Chatme",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontFamily: 'Castro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome back! Sign in using your social account or email to continue us',
                style: TextStyle(fontSize: 14, color: const Color(0xFF797C7B)),
              ),

              SizedBox(height: 32),

              Padding(
                padding: EdgeInsets.all(15),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your email",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Password",
                        style: TextStyle(
                          fontFamily: "CircularStd",
                          fontSize: 14,
                          color: const Color(0xFF24786D),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordcontroller,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 177),
              ElevatedButton(
                onPressed: _onpress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F6F6),
                  fixedSize: Size(327, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Log in",
                  style: TextStyle(
                    fontFamily: 'Caros',
                    fontSize: 16,
                    color: Color(0xFF797C7B),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "CircularStd",
                    fontSize: 14,
                    color: Color(0xFF24786D),
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
