import 'package:flutter/foundation.dart';
import '../models/collection_item.dart';
import '../services/collection_service.dart';

class CollectionController extends ChangeNotifier {
  final CollectionService _service;
  CollectionController(this._service);

  String? currentUserId;
  List<CollectionItem> items = [];
  CollectionSummary? summary;
  bool isLoading = false;
  String? error;

  String searchQuery = '';
  ItemCategory? filterCategory;
  ItemStatus? filterStatus;
  ItemRarity? filterRarity;
  ItemCondition? filterCondition;

  bool get hasActiveFilters =>
      filterCategory != null ||
      filterStatus != null ||
      filterRarity != null ||
      filterCondition != null;

  Future<void> setCurrentUser(String userId) async {
    currentUserId = userId;
    searchQuery = '';
    filterCategory = null;
    filterStatus = null;
    filterRarity = null;
    filterCondition = null;
    await _reload();
  }

  Future<void> loadItems() async {
    if (currentUserId == null) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.getItems(
        userId: currentUserId!,
        search: searchQuery.isEmpty ? null : searchQuery,
        category: filterCategory,
        status: filterStatus,
        rarity: filterRarity,
        condition: filterCondition,
      );
    } catch (_) {
      error = 'Erro ao carregar itens.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSummary() async {
    if (currentUserId == null) return;
    try {
      summary = await _service.getSummary(currentUserId!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addItem(CollectionItem item) async {
    await _service.addItem(item);
    await _reload();
  }

  Future<void> updateItem(CollectionItem item) async {
    await _service.updateItem(item);
    await _reload();
  }

  Future<void> deleteItem(String id) async {
    if (currentUserId == null) return;
    await _service.deleteItem(id, currentUserId!);
    await _reload();
  }

  void setSearch(String query) {
    searchQuery = query;
    loadItems();
  }

  void setFilters({
    ItemCategory? category,
    ItemStatus? status,
    ItemRarity? rarity,
    ItemCondition? condition,
    bool clear = false,
  }) {
    if (clear) {
      filterCategory = null;
      filterStatus = null;
      filterRarity = null;
      filterCondition = null;
    } else {
      filterCategory = category;
      filterStatus = status;
      filterRarity = rarity;
      filterCondition = condition;
    }
    loadItems();
  }

  Future<void> _reload() =>
      Future.wait([loadItems(), loadSummary()]);
}
