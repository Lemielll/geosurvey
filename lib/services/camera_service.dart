import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  /// Request permission untuk akses kamera
  /// Mengembalikan true jika permission diberikan, false jika ditolak
  static Future<bool> requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Cek status permission kamera
  static Future<bool> isCameraPermissionGranted() async {
    final PermissionStatus status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Simpan gambar ke cache lokal dengan format nama: [kategori]_[timestamp].jpg
  /// 
  /// Parameters:
  /// - [sourceImagePath]: path file gambar dari kamera
  /// - [kategori]: kategori identifikasi (Depan, Kanan, Kiri, Belakang)
  /// 
  /// Returns:
  /// - Path file yang telah disimpan atau null jika gagal
  static Future<String?> saveImageToCache({
    required String sourceImagePath,
    required String kategori,
  }) async {
    try {
      // Dapatkan cache directory
      final cacheDir = await getTemporaryDirectory();
      
      // Format timestamp untuk nama file (yyyy-MM-dd-HH-mm-ss)
      final timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
      
      // Buat nama file dengan format: [kategori]_[timestamp].jpg
      final fileName = '${kategori}_$timestamp.jpg';
      
      // Path lengkap file di cache
      final filePath = '${cacheDir.path}/$fileName';
      
      // Copy file dari sumber ke cache
      final sourceFile = File(sourceImagePath);
      final cachedFile = await sourceFile.copy(filePath);
      
      // Return path file yang telah disimpan
      return cachedFile.path;
    } catch (e) {
      print('Error menyimpan gambar ke cache: $e');
      return null;
    }
  }

  /// Dapatkan daftar gambar yang tersimpan di cache
  static Future<List<File>> getCachedImages() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final dir = Directory(cacheDir.path);
      
      // Filter hanya file .jpg yang sesuai format
      final files = dir
          .listSync()
          .where((file) => file.path.endsWith('.jpg'))
          .map((file) => File(file.path))
          .toList();
      
      return files;
    } catch (e) {
      print('Error mengambil gambar dari cache: $e');
      return [];
    }
  }

  /// Hapus gambar dari cache
  static Future<bool> deleteImageFromCache(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error menghapus gambar dari cache: $e');
      return false;
    }
  }

  /// Hapus semua gambar dari cache
  static Future<bool> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final dir = Directory(cacheDir.path);
      
      final files = dir
          .listSync()
          .where((file) => file.path.endsWith('.jpg'));
      
      for (var file in files) {
        await File(file.path).delete();
      }
      
      return true;
    } catch (e) {
      print('Error membersihkan cache: $e');
      return false;
    }
  }

  /// Extract kategori dari nama file
  static String? extractCategoryFromFileName(String fileName) {
    try {
      final baseName = fileName.split('/').last;
      final category = baseName.split('_').first;
      return category;
    } catch (e) {
      return null;
    }
  }
}
