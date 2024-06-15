/// Base entity
class Entity {
  /// Create a new entity
  const Entity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// Entity id
  final BigInt? id;

  /// Entity created at
  final DateTime? createdAt;

  /// Entity updated at
  final DateTime? updatedAt;
}
