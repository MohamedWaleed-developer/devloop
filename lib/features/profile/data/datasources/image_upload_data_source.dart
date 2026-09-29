import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton()
class ImageUploadDataSource {
  static const String cloudName = 'vfsdmh4c';
  static const String uploadPreset = 'devloop_upload';

  Future<String> uploadImage(File image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
      ),
    );

    request.fields['upload_preset'] = uploadPreset;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Image upload failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(responseBody);
    final secureUrl = data['secure_url'];

    if (secureUrl == null || secureUrl.toString().isEmpty) {
      throw Exception('Image URL was not returned');
    }

    return secureUrl.toString();
  }
}