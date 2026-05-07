import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import 'image_preview_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isInitialized = false;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Inisialisasi kamera
  Future<void> _initializeCamera() async {
    try {
      // Cek permission kamera
      final hasPermission = await CameraService.requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin akses kamera diperlukan'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Dapatkan daftar kamera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada kamera tersedia'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _cameras = cameras;
        _selectedCameraIndex = 0;
      });

      // Inisialisasi controller kamera
      await _setupCameraController(_cameras[_selectedCameraIndex]);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inisialisasi kamera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Setup controller untuk kamera
  Future<void> _setupCameraController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() => _cameraController = controller);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setup controller: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Tukar kamera (depan/belakang)
  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _cameraController?.dispose();
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  /// Tukar mode flash
  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });
    _cameraController?.setFlashMode(_flashMode);
  }

  /// Ambil foto
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isTakingPhoto) return;

    try {
      setState(() => _isTakingPhoto = true);

      final image = await _cameraController!.takePicture();

      if (mounted) {
        // Navigate ke halaman preview
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewPage(
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Foto Surveyor'),
      ),
      body: _isInitialized && _cameraController != null
          ? Stack(
              children: [
                // Camera Preview
                CameraPreview(_cameraController!),

                // Overlay bingkai panduan di tengah
                _buildGuideOverlay(),

                // Top controls (Flash, Switch Camera)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Flash
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _flashMode == FlashMode.torch
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),

                      // Tombol Switch Camera
                      if (_cameras.length > 1)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.flip_camera_android,
                              color: Colors.white,
                            ),
                            onPressed: _toggleCamera,
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom controls (Shutter button)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: _buildShutterButton(),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menginisialisasi Kamera...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }

  /// Widget tombol shutter
  Widget _buildShutterButton() {
    return Center(
      child: GestureDetector(
        onTap: _isTakingPhoto ? null : _takePicture,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: _isTakingPhoto
                ? Colors.indigo.withOpacity(0.6)
                : Colors.indigo,
            shape: const CircleBorder(),
            child: _isTakingPhoto
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ),
    );
  }

  /// Widget overlay bingkai panduan di tengah layar
  Widget _buildGuideOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bingkai panduan
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon instruksi di dalam bingkai
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Posisikan Objek',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Sesuaikan posisi objek dalam bingkai',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Instruksi di bawah
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'Tekan tombol di bawah untuk mengambil foto',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
