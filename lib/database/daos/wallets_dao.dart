import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/wallets_table.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(AppDatabase db) : super(db);

  // Получение всех кошельков с правильной сортировкой
  Future<List<Wallet>> getAllWallets() async {
    final allWallets = await select(wallets).get();
    return _sortWallets(allWallets);
  }

  // Стрим для автообновления UI
  Stream<List<Wallet>> watchAllWallets() {
    return select(wallets).watch().map((walletsList) => _sortWallets(walletsList));
  }

  // Вспомогательный метод сортировки (Избранное всегда первое)
  List<Wallet> _sortWallets(List<Wallet> list) {
    final mutableList = List<Wallet>.from(list);
    mutableList.sort((a, b) {
      if (a.name == 'Избранное') return -1;
      if (b.name == 'Избранное') return 1;
      // UUID — это строки, их тоже можно сравнивать через compareTo
      return a.id.compareTo(b.id); 
    });
    return mutableList;
  }

  // ПОИСК: теперь принимаем String id
  Future<Wallet> getWalletById(String id) {
    return (select(wallets)..where((t) => t.id.equals(id))).getSingle();
  }

  // УДАЛЕНИЕ: теперь принимаем String id
  Future deleteWallet(String id) {
    return (delete(wallets)..where((t) => t.id.equals(id))).go();
  }
  
  // ОБНОВЛЕНИЕ: Companion теперь сам подхватит String для id
  Future updateWallet(Wallet wallet) => update(wallets).replace(wallet);
}