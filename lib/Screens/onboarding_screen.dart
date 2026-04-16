import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _handleController = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _register() async {
    final handle = _handleController.text.trim();

    if (handle.isEmpty) {
      setState(() {
        _error = 'Please enter a handle';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final result = await ApiService.register(handle, 'DEMO_PUBLIC_KEY');

      if (result.containsKey('buid')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('buid', result['buid']);
        await prefs.setString('handle', result['handle']);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/login');
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Registration failed';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create your AfriBank identity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _handleController,
              decoration: const InputDecoration(
                labelText: 'Choose your @handle',
                hintText: 'e.g., munawar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '3–30 letters, numbers, or underscores',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
