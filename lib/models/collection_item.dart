enum ItemStatus {
  owned('Possuído'),
  wishlist('Lista de Desejos'),
  sold('Vendido'),
  traded('Trocado'),
  loaned('Emprestado');

  const ItemStatus(this.label);
  final String label;
}

enum ItemRarity {
  common('Comum'),
  uncommon('Incomum'),
  rare('Raro'),
  ultraRare('Ultra Raro');

  const ItemRarity(this.label);
  final String label;
}

enum ItemCondition {
  mint('Mint'),
  nearMint('Near Mint'),
  good('Bom'),
  fair('Regular'),
  poor('Ruim');

  const ItemCondition(this.label);
  final String label;
}

enum ItemCategory {
  books('Livros'),
  coins('Moedas'),
  cards('Cartas'),
  figures('Action Figures'),
  games('Jogos'),
  movies('Filmes'),
  records('Discos'),
  stamps('Selos'),
  comics('Quadrinhos'),
  miniatures('Miniaturas'),
  sneakers('Tênis'),
  shirts('Camisetas'),
  keychains('Chaveiros'),
  other('Outros');

  const ItemCategory(this.label);
  final String label;
}

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
}

class CollectionSummary {
  final int total;
  final int owned;
  final int wishlist;
  final int sold;
  final int traded;
  final int loaned;
  final int repeated;
  final double totalPaid;
  final double totalEstimated;
  final Map<ItemCategory, int> byCategory;

  const CollectionSummary({
    required this.total,
    required this.owned,
    required this.wishlist,
    required this.sold,
    required this.traded,
    required this.loaned,
    required this.repeated,
    required this.totalPaid,
    required this.totalEstimated,
    required this.byCategory,
  });
}
