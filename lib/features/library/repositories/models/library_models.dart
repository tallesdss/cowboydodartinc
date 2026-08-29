import 'package:flutter/foundation.dart';

@immutable
class LibraryCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final DateTime createdAt;

  const LibraryCategory({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '',
    this.color = '',
    required this.createdAt,
  });

  LibraryCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return LibraryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LibraryCategory.fromMap(Map<String, dynamic> map) {
    return LibraryCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String? ?? '',
      color: map['color'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

@immutable
class LibraryAuthor {
  final String id;
  final String name;
  final String bio;
  final DateTime createdAt;
  final String createdBy;

  const LibraryAuthor({
    required this.id,
    required this.name,
    required this.bio,
    required this.createdAt,
    required this.createdBy,
  });

  LibraryAuthor copyWith({
    String? id,
    String? name,
    String? bio,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return LibraryAuthor(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory LibraryAuthor.fromMap(Map<String, dynamic> map) {
    return LibraryAuthor(
      id: map['id'] as String,
      name: map['name'] as String,
      bio: map['bio'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String? ?? '',
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
  final String? authorId;
  final String fileUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final DateTime createdAt;
  final String createdBy;
  final int views;
  final int downloads;

  const PdfDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryIds,
    required this.author,
    this.authorId,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.tags,
    required this.createdAt,
    required this.createdBy,
    this.views = 0,
    this.downloads = 0,
  });

  PdfDocument copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? categoryIds,
    String? author,
    String? authorId,
    String? fileUrl,
    String? thumbnailUrl,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
    int? views,
    int? downloads,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryIds: categoryIds ?? this.categoryIds,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryIds': categoryIds,
      'author': author,
      if (authorId != null) 'authorId': authorId,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'views': views,
      'downloads': downloads,
    };
  }

  factory PdfDocument.fromMap(Map<String, dynamic> map) {
    return PdfDocument(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      categoryIds: List<String>.from(map['categoryIds'] as List),
      author: map['author'] as String,
      authorId: map['authorId'] as String?,
      fileUrl: map['fileUrl'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      tags: List<String>.from(map['tags'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as String,
      views: map['views'] as int? ?? 0,
      downloads: map['downloads'] as int? ?? 0,
    );
  }
}

@immutable
class LibraryComment {
  final String id;
  final String pdfId;
  final String userId;
  final String userName;
  final String text;
  final int rating; // 1 to 5 stars
  final DateTime createdAt;

  const LibraryComment({
    required this.id,
    required this.pdfId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  LibraryComment copyWith({
    String? id,
    String? pdfId,
    String? userId,
    String? userName,
    String? text,
    int? rating,
    DateTime? createdAt,
  }) {
    return LibraryComment(
      id: id ?? this.id,
      pdfId: pdfId ?? this.pdfId,
      userId: userId ?? this.userId,
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
      'userId': userId,
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
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String,
      text: map['text'] as String,
      rating: map['rating'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
