import 'dart:async';
import 'dart:typed_data';

import 'package:cowboydodartinc/core/data/entities/upload_result.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageApiProvider = Provider<StorageApi>(
  (ref) => FirebaseStorageApi(
    storage: fb_storage.FirebaseStorage.instance,
  ),
);

abstract class StorageApi {
  /// upload a file to storage and return a stream of the upload progress
  Stream<UploadResult> uploadData(
    Uint8List data,
    String folder,
    String filename, {
    String? mimeType, // ex 'image/jpg'
    bool isPublic = true,
  });

  /// request to delete a file from path
  Future<void> deleteFile(String? path);
}

class FirebaseStorageApi implements StorageApi {
  final fb_storage.FirebaseStorage _storage;

  FirebaseStorageApi({
    required fb_storage.FirebaseStorage storage,
  }) : _storage = storage;

  @override
  Future<void> deleteFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }
    try {
      await _storage.ref(imagePath).delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }

  @override
  Stream<UploadResult> uploadData(
    Uint8List data,
    String folder,
    String filename, {
    String? mimeType,
    bool isPublic = true,
  }) async* {
    final path = '$folder/$filename';
    yield UploadResultProgress(0.0);
    final ref = _storage.ref(path);
    final metadata = mimeType != null ? fb_storage.SettableMetadata(contentType: mimeType) : null;
    final uploadTask = ref.putData(data, metadata);

    await for (final snapshot in uploadTask.snapshotEvents) {
      if (snapshot.totalBytes > 0) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
        yield UploadResultProgress(progress);
      }
    }

    final downloadUrl = await ref.getDownloadURL();
    yield UploadResultCompleted(
      imagePath: path,
      imagePublicUrl: downloadUrl,
    );
  }
}
