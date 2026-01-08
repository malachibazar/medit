import 'package:flutter/cupertino.dart';
import '../app/theme/app_colors.dart';

/// Data model for a folder.
class Folder {
  final int? id;
  final String name;
  final String? color;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sortOrder;

  Folder({
    this.id,
    required this.name,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.sortOrder = 0,
  });

  /// Create Folder from database map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String?,
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at'] as String)
              : null,
      updatedAt:
          map['updated_at'] != null
              ? DateTime.tryParse(map['updated_at'] as String)
              : null,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Convert Folder to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  /// Get the Color object for this folder
  Color get folderColor => AppColors.getFolderColor(color);

  /// Create a copy with updated values
  Folder copyWith({
    int? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Folder(id: $id, name: $name, color: $color)';
}
