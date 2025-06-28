import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Onboardingscreen extends StatelessWidget {
  const Onboardingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/whiteLogo.png'),
            SizedBox(width: 6),
            Text('Chatme', style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 44, 11, 11),
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Caros',
                    fontSize: 68,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Connect friends'),
                    TextSpan(
                      text: ' easily and quickly',
                      style: TextStyle(
                        fontFamily: 'Caros',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 38),
              Text(
                'Our chat app is the perfect way to stay connected with friends and family',
                style: TextStyle(
                  color: const Color(0xFFB9C1BE),
                  fontSize: 16,
                  fontFamily: 'CircularStd',
                ),
              ),
              SizedBox(height: 38),

              ElevatedButton(
                onPressed: () {
                  context.push('/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: Size(327, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Signup with mail',
                  style: TextStyle(
                    color: const Color(0xFF000E08),
                    fontSize: 16,
                    fontFamily: 'Caros',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 38),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Existing account?',
                    style: TextStyle(
                      color: const Color.fromARGB(96, 234, 234, 234),
                      fontSize: 14,
                      fontFamily: 'CircularStd',
                    ),
                  ),
                  SizedBox(width: 5),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      context.push('/login');
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
