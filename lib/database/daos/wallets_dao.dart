import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/wallets_table.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(AppDatabase db) : super(db);

  Future<List<Wallet>> getAllWallets() async {
    final allWallets = await select(wallets).get();
    
    // Сортируем: Избранное всегда первое
    allWallets.sort((a, b) {
      if (a.name == 'Избранное') return -1; // Если Избранное, ставим выше
      if (b.name == 'Избранное') return 1;  // Если второе Избранное, первое выше
      return a.id.compareTo(b.id);          // Остальные сортируем по ID (или как тебе удобно)
    });
    
    return allWallets;
  }

  // Изменяем Stream, чтобы он тоже всегда выдавал отсортированный список
  Stream<List<Wallet>> watchAllWallets() {
    return select(wallets).watch().map((walletsList) {
      walletsList.sort((a, b) {
        if (a.name == 'Избранное') return -1;
        if (b.name == 'Избранное') return 1;
        return a.id.compareTo(b.id);
      });
      return walletsList;
    });
  }

  Future<int> insertWallet(WalletsCompanion wallet) => into(wallets).insert(wallet);

  Future<bool> updateWallet(Wallet wallet) => update(wallets).replace(wallet);

  Future<int> deleteWallet(Wallet wallet) async {
    if (wallet.name.toLowerCase() == 'избранное') {
      return 0; // Защита: отменяем удаление и возвращаем 0
    }
    return delete(wallets).delete(wallet);
  }
}