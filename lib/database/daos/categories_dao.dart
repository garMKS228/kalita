import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/categories_table.dart'; // Путь к твоей таблице

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(AppDatabase db) : super(db);

  // Получить все категории
  Future<List<Category>> getAllCategories() => select(categories).get();

  // Добавить категорию
  Future<int> insertCategory(CategoriesCompanion category) => into(categories).insert(category);

  // Удалить категорию
  Future<int> deleteCategory(Category category) => delete(categories).delete(category);

  // Обновить категорию
  Future<bool> updateCategory(Category category) => update(categories).replace(category);
}