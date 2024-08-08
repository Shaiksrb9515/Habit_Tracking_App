import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class HabitProvider with ChangeNotifier {
  final CollectionReference _habitsCollection = FirebaseFirestore.instance.collection('habits');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  HabitProvider() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> addHabit(String name, String description, DateTime scheduledDateTime, String? ringtonePath) async {
    DocumentReference habitRef = await _habitsCollection.add({
      'name': name,
      'description': description,
      'createdAt': DateTime.now(),
      'completedDates': [],
      'scheduledDateTime': scheduledDateTime,
      'ringtonePath': ringtonePath,
    });
    notifyListeners();
    scheduleNotification(habitRef.id, name, scheduledDateTime, ringtonePath);
  }

  Future<void> updateHabit(String id, String name, String description) async {
    await _habitsCollection.doc(id).update({
      'name': name,
      'description': description,
    });
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _habitsCollection.doc(id).delete();
    notifyListeners();
  }

  Stream<QuerySnapshot> get habits {
    return _habitsCollection.snapshots();
  }

  Future<void> markHabitCompleted(String id, DateTime date) async {
    DocumentSnapshot doc = await _habitsCollection.doc(id).get();
    List completedDates = doc['completedDates'];
    completedDates.add(date);
    await _habitsCollection.doc(id).update({
      'completedDates': completedDates,
    });
    notifyListeners();
  }

  Future<void> scheduleNotification(String id, String habitName, DateTime scheduledTime, String? ringtonePath) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'habit_tracker_channel',
      'Habit Tracker',
      channelDescription: 'Channel for habit tracker notifications',
      importance: Importance.max,
      priority: Priority.high,
      sound: ringtonePath != null ? RawResourceAndroidNotificationSound(ringtonePath) : null,
      playSound: ringtonePath != null,
      showWhen: false,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      'Habit Reminder',
      'Don\'t forget to complete your habit: $habitName',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
