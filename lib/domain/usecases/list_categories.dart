import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class ListCategories {
  final ExpenseRepository repo;
  ListCategories(this.repo);
  Future<List<Category>> call() => repo.allCategories();
}
