import 'package:flutter/material.dart';

class SendMoneyScreen extends StatelessWidget {
  const SendMoneyScreen({super.key});

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
              'Send Money',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipient',
                hintText: '@handle or scan QR',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '10.00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('USD'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'FX Quote',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('You send: \$10.00 USD'),
            const Text('Recipient gets: €9.20 EUR'),
            const Text('Mid rate: 0.9200'),
            const Text('Spread: 0.5%'),
            const Text('Fee: \$0.50'),
            const Text('⏳ Expires in: 58s'),
            const Text(
              'Last updated: 2025-12-01 16:00 UTC (ECB reference)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transfer queued!')),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushNamed(context, '/history');
                  });
                },
                child: const Text('Confirm & Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
