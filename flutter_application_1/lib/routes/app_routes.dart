import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const WelcomeScreen(),
    '/chatscreen': (context) => const ChatScreen(),
    '/settings':(context)=> const SettingsScreen(),
    '/login': (context) => const LoginScreen(),
    '/profile':(context)=> const ProfileScreen(),
  };
}



