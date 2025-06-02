import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageConstants {
  static final ImageConstants constants = ImageConstants._();
  factory ImageConstants() => constants;
  ImageConstants._();

  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and returns its bytes or null if cancelled.
  Future<Uint8List?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      // Handle error if necessary
    }
    return null;
  }

  /// Converts image bytes (Uint8List) to Base64 string with data URI prefix.
  String convertToBase64(Uint8List bytes) {
    String base64Image = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64Image';
  }

  /// Converts a File's bytes synchronously to Base64 string with data URI prefix.
  String convertFileToBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64Image';
  }

  /// Converts a base64 string to a File object.
  Future<File> base64ToFile(String base64String, String filePath) async {
    Uint8List bytes = decodeBase64(base64String);
    return File(filePath)..writeAsBytesSync(bytes);
  }

  /// Decodes a base64 string (with or without data URI prefix) to bytes.
  Uint8List decodeBase64(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    final pureBase64 = base64String.replaceAll(regex, '');
    return base64Decode(pureBase64);
  }
}
