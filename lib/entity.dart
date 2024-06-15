/// Base entity
class Entity {
  /// Create a new entity
  const Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Entity id
  final BigInt id;

  /// Entity created at
  final DateTime createdAt;

  /// Entity updated at
  final DateTime updatedAt;
}
