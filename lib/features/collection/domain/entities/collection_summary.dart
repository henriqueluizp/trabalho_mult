import 'enums.dart';

class CollectionSummary {
  final int totalItems;
  final int ownedItems;
  final int wishlistItems;
  final int soldItems;
  final int tradedItems;
  final int loanedItems;
  final int repeatedItems;
  final double totalPaidValue;
  final double totalEstimatedValue;
  final Map<ItemCategory, int> itemsByCategory;

  const CollectionSummary({
    required this.totalItems,
    required this.ownedItems,
    required this.wishlistItems,
    required this.soldItems,
    required this.tradedItems,
    required this.loanedItems,
    required this.repeatedItems,
    required this.totalPaidValue,
    required this.totalEstimatedValue,
    required this.itemsByCategory,
  });
}
