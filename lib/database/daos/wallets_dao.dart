import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/wallets_table.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(AppDatabase db) : super(db);

  Future<List<Wallet>> getAllWallets() => select(wallets).get();

  // Стрим для отслеживания баланса в реальном времени
  Stream<List<Wallet>> watchAllWallets() => select(wallets).watch();

  Future<int> insertWallet(WalletsCompanion wallet) => into(wallets).insert(wallet);

  Future<bool> updateWallet(Wallet wallet) => update(wallets).replace(wallet);

  Future<int> deleteWallet(Wallet wallet) => delete(wallets).delete(wallet);
}