import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChatCache {
  static const String _prefsKey = 'cached_chat_ids';

  ChatCache._();

  static Future<Map<String, int>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map(
          (key, value) {
            final id = int.tryParse(key.toString());
            final chatId = value is num
                ? value.toInt()
                : int.tryParse(value?.toString() ?? '');
            if (id == null || chatId == null) return MapEntry('', 0);
            return MapEntry(id.toString(), chatId);
          },
        )..removeWhere((key, value) => key.isEmpty || value == 0);
      }
    } catch (_) {}

    return {};
  }

  static Future<void> _writeCache(Map<String, int> cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(cache));
  }

  static Future<int?> getChatIdForUser(int userId) async {
    final cache = await _readCache();
    return cache[userId.toString()];
  }

  static Future<void> setChatIdForUser(int userId, int chatId) async {
    if (chatId <= 0) return;
    final cache = await _readCache();
    final key = userId.toString();
    if (cache[key] == chatId) return;
    cache[key] = chatId;
    await _writeCache(cache);
  }

  static Future<void> removeChatIdForUser(int userId) async {
    final cache = await _readCache();
    if (cache.remove(userId.toString()) != null) {
      await _writeCache(cache);
    }
  }

  static Future<void> cacheChats(Map<int, int> entries) async {
    if (entries.isEmpty) return;
    final cache = await _readCache();
    var dirty = false;
    for (final entry in entries.entries) {
      if (entry.value <= 0) continue;
      final key = entry.key.toString();
      final existing = cache[key];
      if (existing == entry.value) continue;
      cache[key] = entry.value;
      dirty = true;
    }
    if (dirty) {
      await _writeCache(cache);
    }
  }
}
