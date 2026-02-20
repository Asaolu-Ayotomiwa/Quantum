import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload profile picture
  Future<String?> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');

      // Upload file
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload property images
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<File> imageFiles,
    Function(int, int)? onProgress,
  }) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = 'property_${propertyId}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('properties/$propertyId/$fileName');

        // Upload file
        final uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // Listen to progress (optional)
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (onProgress != null) {
            final progress = (snapshot.bytesTransferred / snapshot.totalBytes * 100).toInt();
            onProgress(i + 1, imageFiles.length);
          }
        });

        // Wait for upload to complete
        final taskSnapshot = await uploadTask;

        // Get download URL
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      print('Error uploading property images: $e');
      return downloadUrls; // Return whatever was uploaded before error
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress to 80% quality
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({int maxImages = 10}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      // Limit to maxImages
      final limitedImages = images.take(maxImages).toList();

      return limitedImages.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Delete file from storage
  Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  // Delete multiple files
  Future<void> deleteFiles(List<String> downloadUrls) async {
    for (String url in downloadUrls) {
      await deleteFile(url);
    }
  }

  // Delete all property images
  Future<void> deletePropertyImages(String propertyId) async {
    try {
      final ref = _storage.ref().child('properties/$propertyId');
      final listResult = await ref.listAll();

      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting property images: $e');
    }
  }

  // Get file size in MB
  double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  // Validate image file
  bool isValidImage(File file, {double maxSizeMB = 10}) {
    // Check file size
    if (getFileSizeInMB(file) > maxSizeMB) {
      return false;
    }

    // Check file extension
    final ext = path.extension(file.path).toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

    return validExtensions.contains(ext);
  }
}