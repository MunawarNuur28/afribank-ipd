import 'package:flutter/material.dart';
import 'package:afribank_ipd/screens/onboarding_screen.dart';
import 'package:afribank_ipd/screens/login_screen.dart';
import 'package:afribank_ipd/screens/send_money_screen.dart';
import 'package:afribank_ipd/screens/history_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/send':
        return MaterialPageRoute(builder: (_) => const SendMoneyScreen());
      case '/history':
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    }
  }
}
