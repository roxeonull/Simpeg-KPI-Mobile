import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';

class NotificationStorage {
  static const String _key = 'simpeg_kpi_notifications';

  /// Get all stored notifications, sorted newest first
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_key);
      if (rawList == null || rawList.isEmpty) return [];

      final list = rawList
          .map((itemStr) {
            try {
              final Map<String, dynamic> map = jsonDecode(itemStr);
              return NotificationItem.fromJson(map);
            } catch (e) {
              return null;
            }
          })
          .whereType<NotificationItem>()
          .toList();

      // Sort descending by timestamp
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    } catch (e) {
      debugPrint("Failed to load notifications from storage: $e");
      return [];
    }
  }

  /// Save a single notification item (prevents duplicate IDs)
  Future<void> saveNotification(NotificationItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getNotifications();

      // Remove existing item with same ID if any
      currentList.removeWhere((n) => n.id == item.id);
      currentList.insert(0, item);

      // Keep maximum 100 recent notifications
      final trimmedList = currentList.take(100).toList();

      final stringList = trimmedList.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_key, stringList);
    } catch (e) {
      debugPrint("Failed to save notification to storage: $e");
    }
  }

  /// Mark notification by ID as read
  Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getNotifications();

      final index = currentList.indexWhere((n) => n.id == id);
      if (index != -1) {
        currentList[index] = currentList[index].copyWith(isRead: true);
        final stringList = currentList.map((n) => jsonEncode(n.toJson())).toList();
        await prefs.setStringList(_key, stringList);
      }
    } catch (e) {
      debugPrint("Failed to mark notification as read: $e");
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getNotifications();

      final updatedList = currentList.map((n) => n.copyWith(isRead: true)).toList();
      final stringList = updatedList.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_key, stringList);
    } catch (e) {
      debugPrint("Failed to mark all notifications as read: $e");
    }
  }

  /// Delete a notification by ID
  Future<void> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await getNotifications();

      currentList.removeWhere((n) => n.id == id);
      final stringList = currentList.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_key, stringList);
    } catch (e) {
      debugPrint("Failed to delete notification: $e");
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint("Failed to clear notifications: $e");
    }
  }
}
