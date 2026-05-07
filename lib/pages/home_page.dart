import 'package:flutter/material.dart';
import 'camera_page.dart';
import '../services/camera_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _cachedImageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCachedImages();
  }

  /// Load jumlah gambar yang sudah disimpan
  Future<void> _loadCachedImages() async {
    final images = await CameraService.getCachedImages();
    setState(() => _cachedImageCount = images.length);
  }

  /// Navigasi ke halaman kamera
  void _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );

    // Refresh cache count setelah kembali dari kamera
    if (result == true || mounted) {
      _loadCachedImages();
    }
  }

  /// Tampilkan dialog untuk menghapus semua cache
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Foto?'),
        content: const Text(
          'Ini akan menghapus semua foto yang telah disimpan. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await CameraService.clearCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua foto telah dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadCachedImages();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoSurvey'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.location_on,
                      size: 64,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selamat Datang di GeoSurvey',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Abadikan dan pemetaan data geografis dengan mudah',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Section
                  Text(
                    'Ambil Foto',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: Card(
                      color: Colors.indigo.withOpacity(0.05),
                      child: InkWell(
                        onTap: _openCamera,
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Buka Kamera',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ambil foto surveyor baru',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cached Images Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Foto Tersimpan',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (_cachedImageCount > 0)
                        TextButton.icon(
                          onPressed: _showClearCacheDialog,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus Semua'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cached Image Count Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Foto',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_cachedImageCount Foto',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                        ),
                        const SizedBox(height: 8),
                        // Text(
                        //   'Foto disimpan di penyimpanan cache lokal',
                        //   style:
                        //       Theme.of(context).textTheme.bodySmall?.copyWith(
                        //             color: Colors.grey[500],
                        //           ),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info Section
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.blue[50],
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(
                  //       color: Colors.blue.withOpacity(0.3),
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.info_outline,
                  //             color: Colors.blue,
                  //             size: 24,
                  //           ),
                  //           const SizedBox(width: 12),
                  //           Text(
                  //             'Informasi',
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .titleSmall
                  //                 ?.copyWith(
                  //                   fontWeight: FontWeight.bold,
                  //                   color: Colors.blue,
                  //                 ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 12),
                  //       // Text(
                  //       //   'Format nama file: [Kategori]_[Tanggal-Jam]',
                  //       //   style: Theme.of(context).textTheme.bodySmall,
                  //       // ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         'Contoh: Depan_2024-12-20-14-30-45.jpg',
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .bodySmall
                  //             ?.copyWith(
                  //               fontStyle: FontStyle.italic,
                  //               color: Colors.grey[600],
                  //             ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
