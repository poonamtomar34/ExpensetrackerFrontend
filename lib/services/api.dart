import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late final String baseUrl = dotenv.env['baseUrl']!;

  Future<http.Response> post(String path, Map body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.get(uri, headers: headers);
  }

  Future<http.Response> put(String path, Map body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return http.delete(uri, headers: headers);
  }

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> body) async {
    final res = await post('/auth/register', body);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final token = decoded['data'] != null && decoded['data']['token'] is String
        ? decoded['data']['token'] as String
        : null;
    if (token != null) await saveToken(token);
    return decoded;
  }

  Future<Map<String, dynamic>> userLogin(Map<String, dynamic> body) async {
    final res = await post('/auth/login', body);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final token = decoded['data'] != null && decoded['data']['token'] is String
        ? decoded['data']['token'] as String
        : null;
    if (token != null) await saveToken(token);
    return decoded;
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> body) async {
    final token = await getToken();
    final res = await post('/expenses', body, token: token);
    handleAuthError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExpenses() async {
    final token = await getToken();
    final res = await get('/expenses', token: token);
    handleAuthError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExpense(
    String id,
    Map<String, dynamic> body,
  ) async {
    final token = await getToken();
    final res = await put('/expenses/$id', body, token: token);
    handleAuthError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteExpensesBulk(List<String> ids) async {
    final token = await getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/expenses/bulk'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'ids': ids}),
    );
    handleAuthError(res);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getExpenseSummary() async {
    final token = await getToken();
    final res = await get('/expenses/summary', token: token);
    handleAuthError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void handleAuthError(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      final context = navigatorKey.currentContext;
      if (context == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
