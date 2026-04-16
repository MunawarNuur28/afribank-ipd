import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080';

  static Future<Map<String, dynamic>> register(
    String handle,
    String publicKey,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'handle': handle, 'publicKey': publicKey}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getChallenge(String handle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/challenge'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'handle': handle}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verify(
    String challengeId,
    String signature,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'challengeId': challengeId, 'signature': signature}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getBalance(String buid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/balance?buid=$buid'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> transfer(
    String senderBuid,
    String recipientHandle,
    double amount,
    String fromCurrency,
    String toCurrency,
    String idempotencyKey,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: {
        'Content-Type': 'application/json',
        'Idempotency-Key': idempotencyKey,
      },
      body: jsonEncode({
        'senderBuid': senderBuid,
        'recipientHandle': recipientHandle,
        'amount': amount,
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'idempotencyKey': idempotencyKey,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getTransactions(String buid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/transactions?buid=$buid'),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFxQuote(
    String from,
    String to,
    double amount,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/fx/quote?from=$from&to=$to&amount=$amount'),
    );
    return jsonDecode(response.body);
  }
}
