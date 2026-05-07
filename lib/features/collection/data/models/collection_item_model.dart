import '../../domain/entities/collection_item.dart';
import '../../domain/entities/enums.dart';

class CollectionItemModel extends CollectionItem {
  const CollectionItemModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.category,
    required super.status,
    super.condition,
    super.paidValue,
    super.estimatedValue,
    super.location,
    required super.rarity,
    super.notes,
    super.imagePath,
    super.isRepeated = false,
    required super.createdAt,
    super.updatedAt,
  });

  factory CollectionItemModel.fromMap(Map<String, dynamic> map) {
    return CollectionItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      name: map['name'] as String,
      category: ItemCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ItemCategory.other,
      ),
      status: ItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ItemStatus.owned,
      ),
      condition: map['condition'] != null
          ? ItemCondition.values.firstWhere(
              (e) => e.name == map['condition'],
              orElse: () => ItemCondition.good,
            )
          : null,
      paidValue: map['paid_value'] as double?,
      estimatedValue: map['estimated_value'] as double?,
      location: map['location'] as String?,
      rarity: ItemRarity.values.firstWhere(
        (e) => e.name == map['rarity'],
        orElse: () => ItemRarity.common,
      ),
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      isRepeated: (map['is_repeated'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category.name,
      'status': status.name,
      'condition': condition?.name,
      'paid_value': paidValue,
      'estimated_value': estimatedValue,
      'location': location,
      'rarity': rarity.name,
      'notes': notes,
      'image_path': imagePath,
      'is_repeated': isRepeated ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory CollectionItemModel.fromEntity(CollectionItem entity) {
    return CollectionItemModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      category: entity.category,
      status: entity.status,
      condition: entity.condition,
      paidValue: entity.paidValue,
      estimatedValue: entity.estimatedValue,
      location: entity.location,
      rarity: entity.rarity,
      notes: entity.notes,
      imagePath: entity.imagePath,
      isRepeated: entity.isRepeated,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
