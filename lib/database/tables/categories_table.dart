import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get system_tag => text()();
  TextColumn get icon_name => text()(); 
} 
