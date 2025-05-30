import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageConstants {
  static final ImageConstants constants = ImageConstants._();
  factory ImageConstants() => constants;
  ImageConstants._();

  String convertToBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64Image';
  }

  /// Decodes base64 string (with or without data:image/... prefix) to bytes
  Uint8List decodeBase64(String base64String) {
    // Remove prefix if exists (data:image/jpeg;base64,)
    final regex = RegExp(r'data:image/[^;]+;base64,');
    final pureBase64 = base64String.replaceAll(regex, '');
    return base64Decode(pureBase64);
  }
}
