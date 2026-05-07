import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

abstract class ImageHelper {
  static Future<String?> pickFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return _saveToAppDir(picked.path);
  }

  static Future<String?> pickFromCamera() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return _saveToAppDir(picked.path);
  }

  static Future<String> _saveToAppDir(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/collection_images');
    await imagesDir.create(recursive: true);
    final ext = p.extension(sourcePath);
    final fileName = '${const Uuid().v4()}$ext';
    final saved = await File(sourcePath).copy('${imagesDir.path}/$fileName');
    return saved.path;
  }

  static Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
