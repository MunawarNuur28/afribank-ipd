import 'package:flutter/material.dart';
import 'package:afribank_ipd/Screens/onboarding_screen.dart';
import 'package:afribank_ipd/Screens/login_screen.dart';
import 'package:afribank_ipd/Screens/send_money_screen.dart';
import 'package:afribank_ipd/Screens/history_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/send':
        return MaterialPageRoute(builder: (_) => const MainShell(index: 0));
      case '/history':
        return MaterialPageRoute(builder: (_) => const MainShell(index: 1));
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    }
  }
}

class MainShell extends StatefulWidget {
  final int index;
  const MainShell({super.key, this.index = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  final List<Widget> _screens = const [SendMoneyScreen(), HistoryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Send'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
