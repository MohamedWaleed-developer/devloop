import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

class UploadedPostImage {
  final String secureUrl;
  final String publicId;

  const UploadedPostImage({
    required this.secureUrl,
    required this.publicId,
  });
}

@LazySingleton()
class PostImageUploadDataSource {
  static const String cloudName = 'vfsdmh4c';
  static const String uploadPreset = 'devloop_upload';

  Future<UploadedPostImage> uploadImage(File image) async {
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
    final publicId = data['public_id'];

    if (secureUrl == null || secureUrl.toString().isEmpty) {
      throw Exception('Image URL was not returned');
    }

    if (publicId == null || publicId.toString().isEmpty) {
      throw Exception('Image public ID was not returned');
    }

    return UploadedPostImage(
      secureUrl: secureUrl.toString(),
      publicId: publicId.toString(),
    );
  }
}