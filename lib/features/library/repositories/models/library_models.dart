import 'package:flutter/foundation.dart';

@immutable
class LibraryCategory {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  const LibraryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  LibraryCategory copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return LibraryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LibraryCategory.fromMap(Map<String, dynamic> map) {
    return LibraryCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

@immutable
class PdfDocument {
  final String id;
  final String title;
  final String description;
  final List<String> categoryIds;
  final String author;
  final String fileUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String createdBy;

  const PdfDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryIds,
    required this.author,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.tags,
    required this.createdAt,
    required this.createdBy,
  });

  PdfDocument copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? categoryIds,
    String? author,
    String? fileUrl,
    String? thumbnailUrl,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryIds: categoryIds ?? this.categoryIds,
      author: author ?? this.author,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryIds': categoryIds,
      'author': author,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory PdfDocument.fromMap(Map<String, dynamic> map) {
    return PdfDocument(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      categoryIds: List<String>.from(map['categoryIds'] as List),
      author: map['author'] as String,
      fileUrl: map['fileUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      tags: List<String>.from(map['tags'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String,
    );
  }
}

@immutable
class LibraryComment {
  final String id;
  final String pdfId;
  final String userName;
  final String text;
  final int rating; // 1 to 5 stars
  final DateTime createdAt;

  const LibraryComment({
    required this.id,
    required this.pdfId,
    required this.userName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  LibraryComment copyWith({
    String? id,
    String? pdfId,
    String? userName,
    String? text,
    int? rating,
    DateTime? createdAt,
  }) {
    return LibraryComment(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pdfId': pdfId,
      'userName': userName,
      'text': text,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LibraryComment.fromMap(Map<String, dynamic> map) {
    return LibraryComment(
      id: map['id'] as String,
      pdfId: map['pdfId'] as String,
      userName: map['userName'] as String,
      text: map['text'] as String,
      rating: map['rating'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
