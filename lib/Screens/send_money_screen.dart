import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  String _currency = 'USD';
  bool _loading = false;
  bool _sending = false;
  String _error = '';
  Map<String, dynamic>? _quote;
  Timer? _quoteTimer;
  int _secondsLeft = 60;

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _getQuote() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Enter a valid amount';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _quote = null;
    });

    try {
      final quote = await ApiService.getFxQuote(_currency, 'EUR', amount);
      setState(() {
        _quote = quote;
        _secondsLeft = 60;
      });

      _quoteTimer?.cancel();
      _quoteTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          _secondsLeft--;
        });
        if (_secondsLeft <= 0) {
          t.cancel();
          setState(() {
            _quote = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch FX quote';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _send() async {
    final prefs = await SharedPreferences.getInstance();
    final senderBuid = prefs.getString('buid') ?? '';
    print('DEBUG senderBuid: $senderBuid');

    final recipient = _recipientController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (recipient.isEmpty) {
      setState(() {
        _error = 'Enter a recipient @handle';
      });
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Enter a valid amount';
      });
      return;
    }

    setState(() {
      _sending = true;
      _error = '';
    });

    try {
      final idempotencyKey = const Uuid().v4();
      final result = await ApiService.transfer(
        senderBuid,
        recipient,
        amount,
        _currency,
        'EUR',
        idempotencyKey,
      );

      if (result.containsKey('status')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer ${result['status']}!')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushNamed(context, '/history');
        });
      } else {
        setState(() {
          _error = result['error'] ?? 'Transfer failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server';
      });
    }

    setState(() {
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AfriBank')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Money',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient',
                hintText: '@handle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: '10.00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _currency,
                  items: _currencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    _currency = val!;
                    _quote = null;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : _getQuote,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Get FX Quote'),
              ),
            ),

            if (_quote != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FX Quote',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('You send: ${_quote!['sendAmount']} $_currency'),
                    Text('They receive: ${_quote!['theyReceive']} EUR'),
                    Text('Mid rate: ${_quote!['midRate']}'),
                    Text('Spread: ${_quote!['spreadFee']}'),
                    Text('Fee: \$${_quote!['flatFee']}'),
                    Text(
                      '⏳ Expires in: ${_secondsLeft}s',
                      style: TextStyle(
                        color: _secondsLeft < 10 ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_quote!['source']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const CircularProgressIndicator()
                    : const Text('Confirm & Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
