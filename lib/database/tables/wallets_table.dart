import 'package:drift/drift.dart';

class Wallets extends Table {
  TextColumn get id => text()(); // ID теперь строка (UUID)
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get color => text()();
  
  @override
  Set<Column> get primaryKey => {id}; // Явно указываем первичный ключ
}