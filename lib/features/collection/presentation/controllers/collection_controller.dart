import 'package:flutter/foundation.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/entities/collection_summary.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/add_item_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/get_summary_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';

class CollectionController extends ChangeNotifier {
  final AddItemUseCase _addItem;
  final UpdateItemUseCase _updateItem;
  final DeleteItemUseCase _deleteItem;
  final GetItemsUseCase _getItems;
  final GetSummaryUseCase _getSummary;

  CollectionController({
    required AddItemUseCase addItem,
    required UpdateItemUseCase updateItem,
    required DeleteItemUseCase deleteItem,
    required GetItemsUseCase getItems,
    required GetSummaryUseCase getSummary,
  })  : _addItem = addItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        _getItems = getItems,
        _getSummary = getSummary;

  String? _currentUserId;
  List<CollectionItem> _items = [];
  CollectionSummary? _summary;
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  ItemCategory? _filterCategory;
  ItemStatus? _filterStatus;
  ItemRarity? _filterRarity;
  ItemCondition? _filterCondition;

  String? get currentUserId => _currentUserId;
  List<CollectionItem> get items => _items;
  CollectionSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ItemCategory? get filterCategory => _filterCategory;
  ItemStatus? get filterStatus => _filterStatus;
  ItemRarity? get filterRarity => _filterRarity;
  ItemCondition? get filterCondition => _filterCondition;

  bool get hasActiveFilters =>
      _filterCategory != null ||
      _filterStatus != null ||
      _filterRarity != null ||
      _filterCondition != null;

  // Chamado após login/cadastro — define o usuário e carrega seus dados
  Future<void> setCurrentUser(String userId) async {
    _currentUserId = userId;
    _searchQuery = '';
    _filterCategory = null;
    _filterStatus = null;
    _filterRarity = null;
    _filterCondition = null;
    await _recarregar();
  }

  Future<void> loadItems() async {
    if (_currentUserId == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _getItems(
        userId: _currentUserId!,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        category: _filterCategory,
        status: _filterStatus,
        rarity: _filterRarity,
        condition: _filterCondition,
      );
    } catch (_) {
      _error = 'Erro ao carregar itens. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSummary() async {
    if (_currentUserId == null) return;
    try {
      _summary = await _getSummary(_currentUserId!);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addItem(CollectionItem item) async {
    await _addItem(item);
    await _recarregar();
  }

  Future<void> updateItem(CollectionItem item) async {
    await _updateItem(item);
    await _recarregar();
  }

  Future<void> deleteItem(String id) async {
    if (_currentUserId == null) return;
    await _deleteItem(id, _currentUserId!);
    await _recarregar();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
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
      _filterCategory = null;
      _filterStatus = null;
      _filterRarity = null;
      _filterCondition = null;
    } else {
      _filterCategory = category;
      _filterStatus = status;
      _filterRarity = rarity;
      _filterCondition = condition;
    }
    loadItems();
  }

  Future<void> _recarregar() async {
    await Future.wait([loadItems(), loadSummary()]);
  }
}
