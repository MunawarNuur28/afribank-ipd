import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _handleController = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final handle = _handleController.text.trim().replaceAll('@', '');

      final challenge = await ApiService.getChallenge(handle);

      if (challenge.containsKey('error')) {
        setState(() {
          _error = challenge['error'];
          _loading = false;
        });
        return;
      }

      final result = await ApiService.verify(
        challenge['challengeId'],
        'DEMO_SIGNATURE',
      );

      if (result.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('buid', result['buid']);
        await prefs.setString('handle', result['handle']);
        if (mounted) {
          Navigator.pushNamed(context, '/send');
        }
      } else {
        setState(() {
          _error = result['error'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AfriBank')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _handleController,
              decoration: const InputDecoration(
                labelText: '@handle',
                prefixText: '@',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('No account? Register here'),
            ),
          ],
        ),
      ),
    );
  }
}
