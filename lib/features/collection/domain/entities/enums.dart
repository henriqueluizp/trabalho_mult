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
