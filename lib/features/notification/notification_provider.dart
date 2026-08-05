import 'package:flutter/material.dart';
import '../../core/models/notification_item.dart';
import '../../core/services/notification_storage.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationStorage _storage = NotificationStorage();

  List<NotificationItem> _items = [];
  bool _isLoading = false;
  String _selectedCategory = 'semua';

  List<NotificationItem> get items => _items;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  int get unreadCount => _items.where((item) => !item.isRead).length;

  List<NotificationItem> get filteredItems {
    if (_selectedCategory == 'semua') return _items;
    return _items.where((item) {
      if (_selectedCategory == 'cuti') {
        return item.type == 'cuti';
      } else if (_selectedCategory == 'absensi') {
        return item.type == 'absensi' || item.type == 'sistem';
      } else if (_selectedCategory == 'perubahan_data') {
        return item.type == 'perubahan_data';
      } else if (_selectedCategory == 'pengumuman') {
        return item.type == 'pengumuman' || item.type == 'pelatihan';
      }
      return item.type == _selectedCategory;
    }).toList();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _storage.getNotifications();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  Future<void> addNotification(NotificationItem item) async {
    await _storage.saveNotification(item);
    _items.removeWhere((n) => n.id == item.id);
    _items.insert(0, item);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _storage.markAsRead(id);
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _storage.markAllAsRead();
    _items = _items.map((item) => item.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _storage.deleteNotification(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _storage.clearAll();
    _items.clear();
    notifyListeners();
  }
}
