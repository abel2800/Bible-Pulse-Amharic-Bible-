import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();
  
  List<DevotionReminder> _reminders = [];
  
  List<DevotionReminder> get reminders => _reminders;
  List<DevotionReminder> get activeReminders =>
      _reminders.where((r) => r.isEnabled).toList();
  
  Future<void> loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString('devotion_reminders');
      
      if (remindersJson != null) {
        final List<dynamic> decoded = json.decode(remindersJson);
        _reminders = decoded.map((r) => DevotionReminder.fromJson(r)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading reminders: $e');
    }
  }
  
  Future<void> addReminder(DevotionReminder reminder) async {
    try {
      _reminders.add(reminder);
      await _saveReminders();
      
      if (reminder.isEnabled) {
        await _scheduleReminder(reminder);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding reminder: $e');
    }
  }
  
  Future<void> updateReminder(DevotionReminder reminder) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index == -1) return;
      
      _reminders[index] = reminder;
      await _saveReminders();
      
      await _notificationService.cancelNotification(index);
      
      if (reminder.isEnabled) {
        await _scheduleReminder(reminder);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating reminder: $e');
    }
  }
  
  Future<void> deleteReminder(String id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index == -1) return;
      
      await _notificationService.cancelNotification(index);
      
      _reminders.removeAt(index);
      await _saveReminders();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
    }
  }
  
  Future<void> toggleReminder(String id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index == -1) return;
      
      final reminder = _reminders[index];
      final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
      
      _reminders[index] = updated;
      await _saveReminders();
      
      if (updated.isEnabled) {
        await _scheduleReminder(updated);
      } else {
        await _notificationService.cancelNotification(index);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }
  }
  
  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = json.encode(
        _reminders.map((r) => r.toJson()).toList(),
      );
      await prefs.setString('devotion_reminders', remindersJson);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
    }
  }
  
  Future<void> _scheduleReminder(DevotionReminder reminder) async {
    debugPrint('Scheduling reminder: ${reminder.title} at ${reminder.formattedTime}');
  }
  
  DevotionReminder createDefaultReminder() {
    return DevotionReminder(
      id: _uuid.v4(),
      title: 'Daily Devotion',
      description: 'Time for your daily devotion',
      time: const TimeOfDay(hour: 8, minute: 0),
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Every day
      createdAt: DateTime.now(),
    );
  }
}

