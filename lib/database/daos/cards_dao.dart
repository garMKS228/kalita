import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/cards_table.dart'; 

part 'cards_dao.g.dart'; 

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(AppDatabase db) : super(db);

  // Получение всех карт
  Future<List<CardEntry>> getAllCards() => select(cards).get();

  // Стрим для автообновления списка карт в UI
  Stream<List<CardEntry>> watchAllCards() => select(cards).watch();

  // ПОИСК: теперь принимаем String id
  Future<CardEntry> getCardById(String id) {
    return (select(cards)..where((i) => i.id.equals(id))).getSingle();
  }

  // Получение карт, не привязанных к кошелькам
  Future<List<CardEntry>> getFreeCards() {
    return (select(cards)..where((t) => t.wallet_id.isNull())).get();
  }

  // ПРИВЯЗКА К КОШЕЛЬКУ: параметры теперь String
  Future bindCardToWallet(String cardId, String walletId) {
    return (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(wallet_id: Value(walletId)),
    );
  }

  // ИЗМЕНЕНИЕ СТАТУСА ИЗБРАННОГО: принимаем String id
  Future updateFavoriteStatus(String id, bool isFavorite) {
    return (update(cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(is_favorite: Value(isFavorite)),
    );
  }

  // УДАЛЕНИЕ КАРТЫ: принимаем String id
  Future deleteCard(String id) {
    return (delete(cards)..where((t) => t.id.equals(id))).go();
  }

  // ДОБАВЛЕНИЕ/ОБНОВЛЕНИЕ КАРТЫ
  Future insertCard(CardEntry card) => into(cards).insert(card, mode: InsertMode.insertOrReplace);
  
  Future updateCard(CardEntry card) => update(cards).replace(card);
}