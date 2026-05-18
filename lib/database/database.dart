import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_application_1/database/tables/wallets_table.dart';
import 'package:flutter_application_1/database/tables/cards_table.dart';
import 'package:flutter_application_1/database/tables/categories_table.dart';
import 'package:flutter_application_1/database/daos/categories_dao.dart';
import 'package:flutter_application_1/database/daos/cards_dao.dart';
import 'package:flutter_application_1/database/daos/wallets_dao.dart';

part 'database.g.dart';


@DriftDatabase(
  tables: [ Wallets, Cards, Categories],
  daos: [WalletsDao, CardsDao, CategoriesDao]
  )

class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;


  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      await into(wallets).insert(
      const WalletsCompanion(
        id: Value("default_favorite"),
        name : Value('Избранное'), 
        color: Value('0xFF9276F6'),
      ),
    );

      
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Add migration steps here if needed
    },
    
  );

  Future<void> clearAllData() async {
    await transaction(() async {
      // Удаляем все данные из таблиц
      await delete(cards).go();
      await delete(wallets).go();
      
      // Сразу создаем "Избранное", так как это системный кошелек
      await into(wallets).insert(
        const WalletsCompanion(
          id: Value("default_favorite"),
          name: Value('Избранное'),
          color: Value('0xFF9276F6'),
        ),
      );
    });
  } 
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    String path;
    
    if (Platform.isWindows) {
      final projectRoot = Directory.current.path;
      path = p.join(projectRoot, 'db1.sqlite');
    } else {
      // Для Android/iOS 
      final dbFolder = await getApplicationDocumentsDirectory();
      path = p.join(dbFolder.path, 'db1.sqlite');
    }

    print('Database path: $path'); // Выведет путь в консоль
    final file = File(path);
    
    return NativeDatabase(file, logStatements: true);
  });
}