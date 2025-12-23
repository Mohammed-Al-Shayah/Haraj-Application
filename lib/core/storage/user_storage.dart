import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<int?> getUserIdFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString("_userData");
  if (userJson == null) return null;

  final user = jsonDecode(userJson);

  final id = user['id'] ?? user['user_id'];

  if (id is int) return id;
  if (id is num) return id.toInt();
  if (id is String) return int.tryParse(id);

  return null;
}
