import 'package:drift/drift.dart';
import '../database.dart';
// Убедись, что путь к таблице правильный (cards_table.dart или cards.dart)
import '../tables/cards_table.dart'; 

part 'cards_dao.g.dart'; 

@DriftAccessor(tables: [Cards])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  CardsDao(AppDatabase db) : super(db);

  Future<List<CardEntry>> getAllCards() => select(cards).get();

  Stream<List<CardEntry>> watchAllCards() => select(cards).watch();

  Future<CardEntry> getCardById(int id) {
    return (select(cards)..where((i) => i.id.equals(id))).getSingle();
  }

  // НОВОЕ: Получить все карты, которые не привязаны ни к одному кошельку
  Future<List<CardEntry>> getFreeCards() {
    return (select(cards)..where((t) => t.wallet_id.isNull())).get();
  }

  // НОВОЕ: Привязать существующую карту к кошельку
  Future bindCardToWallet(int cardId, int walletId) {
    return (update(cards)..where((t) => t.id.equals(cardId))).write(
      CardsCompanion(wallet_id: Value(walletId)),
    );
  }

  Future updateFavoriteStatus(int id, bool isFavorite) {
    return (update(cards)..where((t) => t.id.equals(id))).write(
      CardsCompanion(is_favorite: Value(isFavorite ? true : false)),
    );
  }

  Future<int> insertCard(CardsCompanion card) => into(cards).insert(card);

  Future<bool> updateCard(CardEntry card) => update(cards).replace(card);

  Future<int> deleteCard(CardEntry card) => delete(cards).delete(card);
}