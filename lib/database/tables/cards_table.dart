import 'package:drift/drift.dart';
import 'package:flutter_application_1/database/tables/wallets_table.dart';
import 'package:flutter_application_1/database/tables/categories_table.dart';

@DataClassName('CardEntry') 
class Cards extends Table {
  // autoIncrement() уже делает эту колонку первичным ключом!
  IntColumn get id => integer().autoIncrement()(); 
  
  IntColumn get wallet_id => integer().nullable().references(Wallets, #id)();
  IntColumn get category_id => integer().nullable().references(Categories, #id)();
  
  TextColumn get title => text().withLength(min: 1, max: 50)();
  Column get barcode_data => text().withLength(min: 1, max: 50)();
  TextColumn get barcode_type => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().nullable()(); 
  BoolColumn get is_favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lat_used => dateTime().nullable()();
}