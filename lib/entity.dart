/// Base entity
abstract class Entity {
  /// Create a new entity
  const Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id.toInt(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Entity id
  final BigInt id;

  /// Entity created at
  final DateTime createdAt;

  /// Entity updated at
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Entity(id: $id, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
