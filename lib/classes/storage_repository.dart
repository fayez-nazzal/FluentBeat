import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StorageRepository {
  static Future<File?> uploadProfileImage(File file, String userId) async {
    try {
      // imageCache.clear();

      await Amplify.Storage.uploadFile(local: file, key: "$userId.jpg");

      final documentsDir = await getApplicationDocumentsDirectory();
      final filepath = '${documentsDir.path}/$userId.jpg';
      var localFile = File(filepath);

      // check if a previous image file exists, if so, delete it.
      if (await localFile.exists()) {
        localFile.delete();
      }

      // safe file to device ( to be fetched later, fast. )
      await file.copy(filepath);

      return file;
    } catch (e) {
      // rethrow;
    }
  }

  static Future<File?> getImage(String id, String format) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final filepath = '${documentsDir.path}/$id.$format';
      final file = File(filepath);

      // check if file exists, if so, return it
      if (await file.exists()) {
        return file;
      }

      print("getting id.$format");

      // if not, download it
      final result =
          await Amplify.Storage.downloadFile(local: file, key: "$id.$format");

      return File(result.file.path);
    } catch (e) {
      // file not found, do nothing
      return null;
    }
  }
}
