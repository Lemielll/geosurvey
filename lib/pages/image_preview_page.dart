import 'dart:io';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imagePath;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool _isLoading = false;

  /// List kategori identifikasi
  static const List<String> categories = ['Depan', 'Kanan', 'Kiri', 'Belakang'];

  /// Tampilkan bottom sheet untuk memilih kategori
  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Pilih Kategori Identifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Grid kategori
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Widget card untuk setiap kategori
  Widget _buildCategoryCard(String category) {
    return InkWell(
      onTap: () => _saveImageWithCategory(category),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.indigo, width: 2),
          borderRadius: BorderRadius.circular(16),
          color: Colors.indigo.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 40,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Dapatkan icon untuk setiap kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Depan':
        return Icons.arrow_downward;
      case 'Kanan':
        return Icons.arrow_forward;
      case 'Kiri':
        return Icons.arrow_back;
      case 'Belakang':
        return Icons.arrow_upward;
      default:
        return Icons.image;
    }
  }

  /// Simpan gambar dengan kategori yang dipilih
  Future<void> _saveImageWithCategory(String category) async {
    setState(() => _isLoading = true);

    try {
      // Simpan gambar ke cache
      final savedPath = await CameraService.saveImageToCache(
        sourceImagePath: widget.imagePath,
        kategori: category,
      );

      if (mounted) {
        if (savedPath != null) {
          // Tampilkan snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto kategori "$category" telah disimpan'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Kembali ke halaman utama
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Tampilkan snackbar error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan foto. Coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratinjau Foto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Tampilkan gambar
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          // Tombol aksi di bagian bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Ambil Ulang
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ambil Ulang'),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Gunakan Foto
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showCategoryBottomSheet,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Gunakan Foto'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
