import 'enums.dart';

class CollectionItem {
  final String id;
  final String userId;
  final String name;
  final ItemCategory category;
  final ItemStatus status;
  final ItemCondition? condition;
  final double? paidValue;
  final double? estimatedValue;
  final String? location;
  final ItemRarity rarity;
  final String? notes;
  final String? imagePath;
  final bool isRepeated;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CollectionItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.status,
    this.condition,
    this.paidValue,
    this.estimatedValue,
    this.location,
    required this.rarity,
    this.notes,
    this.imagePath,
    this.isRepeated = false,
    required this.createdAt,
    this.updatedAt,
  });

  CollectionItem copyWith({
    String? id,
    String? userId,
    String? name,
    ItemCategory? category,
    ItemStatus? status,
    ItemCondition? condition,
    double? paidValue,
    double? estimatedValue,
    String? location,
    ItemRarity? rarity,
    String? notes,
    String? imagePath,
    bool? isRepeated,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      paidValue: paidValue ?? this.paidValue,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      location: location ?? this.location,
      rarity: rarity ?? this.rarity,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isRepeated: isRepeated ?? this.isRepeated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
