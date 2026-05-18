import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Объект для локальных уведомлений
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
  // Запрос разрешений (на Windows это просто вернет успех или проигнорируется)
  NotificationSettings settings = await _fcm.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('Разрешение получено');

    // Настройки для Android
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // ДОБАВЛЯЕМ настройки для Windows (даже если они пустые)
    // Это уберет ошибку "Windows settings must be set"
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(); // Для iOS/Mac
    const LinuxInitializationSettings linuxInit = LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
      linux: linuxInit,
    );
    
    // В некоторых версиях плагина для Windows нужно передать настройки
    // Если ошибка остается, попробуй просто обернуть инициализацию в проверку платформы
    try {
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Обработка нажатия на уведомление
        },
      );
    } catch (e) {
      debugPrint("Ошибка инициализации на этой платформе: $e");
    }

    // Токен (на Windows FCM работает иначе, поэтому обернем в проверку)
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    }
  }
}

  // МЕТОД ДЛЯ ПРИВЕТСТВЕННОГО ПУША
  Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel', // ID канала
      'Уведомления системы', // Имя канала
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // ИСПРАВЛЕНО: все параметры теперь именованные (id:, title:, body:, notificationDetails:)
    await _localNotifications.show(
      id: 0, 
      title: '🎉 Регистрация успешна!', 
      body: 'Добро пожаловать в Kalita. Ваши карты под защитой!', 
      notificationDetails: details,
    );
  }

  // МЕТОД ПРОВЕРКИ ФЛАГА (Вызываем при входе в login.dart)
  Future<void> checkAndShowWelcomeNotification() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDocRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await userDocRef.get();

      bool welcomeSent = false;
      if (docSnapshot.exists && docSnapshot.data() != null) {
        welcomeSent = docSnapshot.data()?['welcome_sent'] == true;
      }

      // Если еще не отправляли — бахаем пуш и ставим метку в базу
      if (!welcomeSent) {
        await showWelcomeNotification();

        await userDocRef.set({
          'welcome_sent': true,
          'welcome_sent_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        debugPrint("Приветственный пуш отправлен!");
      }
    } catch (e) {
      debugPrint("Ошибка проверки пуша: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore.collection('users').doc(uid).set({
        'fcm_token': token,
        'token_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Ошибка сохранения токена: $e");
    }
  }
}