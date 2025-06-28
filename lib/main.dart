import 'package:five/screens/bottomnavigationscreen.dart';
import 'package:five/screens/chatscreen.dart';
import 'package:five/screens/contactprofilescreen.dart';
import 'package:five/screens/contactscreen.dart';
import 'package:five/screens/contactsearchscreen.dart';
import 'package:five/screens/homescreen.dart';
import 'package:five/screens/loginscreen.dart';
import 'package:five/screens/onboardingscreen.dart';
import 'package:five/screens/signupscreen.dart';
import 'package:five/screens/welcome-screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: const MyApp()));
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const Homescreen()),
    GoRoute(path: '/signup', builder: (context, state) => const Signupscreen()),
    GoRoute(path: '/login', builder: (context, state) => const Loginscreen()),
    GoRoute(path: '/', builder: (context, state) => const Onboardingscreen()),
    GoRoute(
      path: '/contact-list',
      builder: (context, state) => const Contactscreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ContactProfileScreen(),
    ),
    GoRoute(
      path: '/tabscreen',
      builder: (context, state) => Bottomnavigationscreen(),
    ),
    GoRoute(
      path: '/searchcontact',
      builder: (context, state) => ContactSearchScreen(),
    ),
    GoRoute(
      path: '/chatscreen',
      builder: (context, state) {
        final receiverID = state.extra as String;

        return ChatScreen(receiverid: receiverID);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Chatme',
      routerConfig: _router,
    );
  }
}
