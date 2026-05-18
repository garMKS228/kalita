import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/database/database.dart';
import 'package:flutter/foundation.dart';


class FirebaseSyncService {
  final AppDatabase db;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseSyncService(this.db);

  // 1. БЕЗОПАСНЫЙ ГЕТТЕР
  // Теперь мы никогда не вызовем doc(null), что предотвращает жесткие вылеты приложения
  DocumentReference? get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  /// ПУШ ЛОКАЛЬНЫХ ИЗМЕНЕНИЙ В ОБЛАКО (Полная выгрузка)
  Future<void> pushFullDatabaseToCloud() async {
    final docRef = _userDoc;
    if (docRef == null) return;

    try {
      await docRef.set({
        'last_sync': DateTime.now().toIso8601String(),
        'email': _auth.currentUser?.email,
      }, SetOptions(merge: true));

      final wallets = await db.walletsDao.getAllWallets();
      for (var wallet in wallets) {
        await pushWallet(wallet);
      }

      final cards = await db.cardsDao.getAllCards();
      for (var card in cards) {
        await pushCard(card);
      }
      debugPrint("✅ Вся локальная база успешно выгружена в Firestore!");
    } catch (e) {
      debugPrint("❌ Ошибка выгрузки полной базы: $e");
    }
  }

  // ПУШ ОДНОГО КОШЕЛЬКА
  Future<void> pushWallet(Wallet wallet) async {
    final docRef = _userDoc;
    if (docRef == null) return;
    
    await docRef.set({'updated_at': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    await docRef.collection('wallets').doc(wallet.id).set({
      'name': wallet.name,
      'color': wallet.color,
    }, SetOptions(merge: true));
  }

  // ПУШ ОДНОЙ КАРТЫ
  Future<void> pushCard(CardEntry card) async {
    final docRef = _userDoc;
    if (docRef == null) return;

    await docRef.set({'updated_at': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    await docRef.collection('cards').doc(card.id).set({
      'title': card.title,
      'barcode_data': card.barcode_data,
      'barcode_type': card.barcode_type,
      'color': card.color,
      'wallet_id': card.wallet_id, // Если null, Firebase так и запишет
      'is_favorite': card.is_favorite,
    }, SetOptions(merge: true));
  }
  
  // УДАЛЕНИЕ КАРТЫ ИЗ ОБЛАКА (Исправлен тип на String)
  Future<void> deleteCard(String id) async {
    final docRef = _userDoc;
    if (docRef == null) return;
    await docRef.collection('cards').doc(id).delete();
  }

  // УДАЛЕНИЕ КОШЕЛЬКА ИЗ ОБЛАКА
  Future<void> deleteWallet(String id) async {
    final docRef = _userDoc;
    if (docRef == null) return;
    await docRef.collection('wallets').doc(id).delete();
  }

  /// ЗАГРУЗКА ИЗ ОБЛАКА ПРИ ВХОДЕ
  Future<void> pullDatabaseFromCloud(String userId) async {
    try {
      debugPrint("--- НАЧАЛО ЗАГРУЗКИ ИЗ ОБЛАКА ---");
      
      // 2. СПАСИТЕЛЬНАЯ ПАУЗА (Критично для Windows)
      // Даем потокам Firebase время на синхронизацию статуса авторизации
      await _auth.currentUser?.getIdTokenResult(true);

      final userDoc = _firestore.collection('users').doc(userId);


      // Очищаем старую локальную базу
      await db.clearAllData();

      // --- Загружаем кошельки ---
      final walletsSnapshot = await userDoc.collection('wallets').get();
      for (var doc in walletsSnapshot.docs) {
        final data = doc.data();
        
        // Защита от пустых имен (иначе Drift выкинет ошибку)
        String wName = data['name']?.toString() ?? 'Без названия';
        if (wName.isEmpty) wName = 'Без названия';

        await db.into(db.wallets).insert(
          WalletsCompanion(
            id: drift.Value(doc.id), 
            name: drift.Value(wName),
            color: drift.Value(data['color']?.toString() ?? '0xFF9276F6'),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }

      // --- Загружаем карты ---
      final cardsSnapshot = await userDoc.collection('cards').get();
      for (var doc in cardsSnapshot.docs) {
        final data = doc.data();
        
        // Защита от пустых названий
        String tData = data['title']?.toString() ?? 'Без названия';
        if (tData.isEmpty) tData = 'Без названия';

        // Защита от пустых штрихкодов (Drift требует minLength: 1)
        String bData = data['barcode_data']?.toString() ?? ' ';
        if (bData.isEmpty) bData = ' '; 

        // Правильная обработка null для внешнего ключа
        String? wId = data['wallet_id']?.toString();
        if (wId == 'null' || wId == '') wId = null;

        await db.into(db.cards).insert(
          CardsCompanion(
            id: drift.Value(doc.id),
            title: drift.Value(tData),
            wallet_id: drift.Value(wId), // Теперь null передается безопасно
            barcode_data: drift.Value(bData),
            barcode_type: drift.Value(data['barcode_type']?.toString() ?? 'QR'),
            color: drift.Value(data['color']?.toString() ?? '0xFF9276F6'),
            is_favorite: drift.Value(data['is_favorite'] == true),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }

      debugPrint("--- СИНХРОНИЗАЦИЯ ЗАВЕРШЕНА УСПЕШНО ---");
    } catch (e) {
      debugPrint("❌ Ошибка при pullDatabaseFromCloud: $e");
      rethrow; 
    }
  }

  Future<void> updateCardInCloud(CardEntry card) async {
    final doc = _userDoc; // Сохраняем в локальную переменную для корректной проверки на null
    if (doc == null) return;

    try {
      await doc.collection('cards').doc(card.id).set({
        'title': card.title,
        'barcode_data': card.barcode_data,
        'barcode_type': card.barcode_type,
        'color': card.color,
        'is_favorite': card.is_favorite,
        'wallet_id': card.wallet_id,
      }, SetOptions(merge: true));
      debugPrint("Карта ${card.id} обновлена в Firebase");
    } catch (e) {
      debugPrint("Ошибка обновления карты в Firebase: $e");
    }
  }

  // Обновление кошелька в Firebase
  Future<void> updateWalletInCloud(Wallet wallet) async {
    final doc = _userDoc; // Сохраняем в локальную переменную
    if (doc == null) return;

    try {
      await doc.collection('wallets').doc(wallet.id).set({
        'name': wallet.name,
        'color': wallet.color,
      }, SetOptions(merge: true));
      debugPrint("Кошелек ${wallet.id} обновлен в Firebase");
    } catch (e) {
      debugPrint("Ошибка обновления кошелька в Firebase: $e");
    }
  }
}