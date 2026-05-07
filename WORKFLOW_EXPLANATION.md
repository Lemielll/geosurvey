# Dokumentasi Alur Kerja & Penjelasan Kode

## 1. User Journey (Alur dari Perspektif Pengguna)

### Scenario: Ambil dan Simpan Foto Surveyor

```
┌─────────────────────────────────────────────────────────────┐
│                      HOME PAGE                              │
│  [Logo] GeoSurvey                                           │
│  "Selamat Datang di GeoSurvey"                              │
│                                                              │
│  ┌──────────────────────────────────┐                       │
│  │  📷 Buka Kamera                  │  ← CLICK              │
│  │  Ambil foto surveyor baru        │                       │
│  └──────────────────────────────────┘                       │
│                                                              │
│  Foto Tersimpan: 3 Foto                                     │
│  (Info: [Kategori]_[Tanggal-Jam].jpg)                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              CAMERA PAGE (Full Screen)                       │
│                                                              │
│  📷 ┏━━━━━━━━━━━━━━┓                                        │
│   ┃ Camera Preview ┃                                        │
│  ┃ with live feed ┃                                        │
│  ┃   ┌─────────┐  ┃                                        │
│  ┃   │Position │  ┃  ← Guide Frame                        │
│  ┃   │ Objek   │  ┃                                        │
│  ┃   │Dalamngkai┃                                        │
│  ┃   └─────────┘  ┃                                        │
│  ┗━━━━━━━━━━━━━━┛                                        │
│                                                              │
│  [⚡] (Flash)         [↔️] (Flip Camera)                     │
│                     [●] (SHUTTER) ← CLICK                  │
│                                                              │
│  "Tekan tombol untuk mengambil foto"                        │
└────────────────────┬────────────────────────────────────────┘
                     │ takePicture()
                     ▼
┌─────────────────────────────────────────────────────────────┐
│            IMAGE PREVIEW PAGE                               │
│  ← Back                                                      │
│                                                              │
│  ┌──────────────────────────────────┐                       │
│  │    📷 Preview Gambar             │                       │
│  │  (Full size with borders)        │                       │
│  │                                  │                       │
│  │  [Foto yang diambil]             │                       │
│  │                                  │                       │
│  └──────────────────────────────────┘                       │
│                                                              │
│  [← Ambil Ulang] [✓ Gunakan Foto]  ← CLICK "Gunakan"      │
└────────────────────┬────────────────────────────────────────┘
                     │ _showCategoryBottomSheet()
                     ▼
┌─────────────────────────────────────────────────────────────┐
│         CATEGORY SELECTION (Bottom Sheet)                   │
│                                                              │
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║  Pilih Kategori Identifikasi                          ║  │
│  ║                                                       ║  │
│  ║  ┌─────────────┐        ┌─────────────┐              ║  │
│  ║  │   ↓ Depan   │        │   → Kanan   │              ║  │
│  ║  └─────────────┘        └─────────────┘              ║  │
│  ║                                                       ║  │
│  ║  ┌─────────────┐        ┌─────────────┐              ║  │
│  ║  │   ← Kiri    │        │   ↑ Belakang│              ║  │
│  ║  └─────────────┘        └─────────────┘              ║  │
│  ║                                                       ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│                                                              │
└────────────────────┬────────────────────────────────────────┘
                     │ SELECT CATEGORY
                     ▼
         ┌───────────────────────────┐
         │  saveImageToCache()       │
         │  Format: [kategori]_      │
         │  [timestamp].jpg          │
         └───────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  ✅ SUCCESS NOTIFICATION                                    │
│  "Foto kategori 'Depan' telah disimpan"                     │
│                                                              │
│  [AUTO NAVIGATE BACK TO HOME PAGE]                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              HOME PAGE (Updated)                            │
│                                                              │
│  Foto Tersimpan: 4 Foto ✓ (Updated count)                  │
│  Depan_2024-12-20-14-30-45.jpg                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Technical Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      MaterialApp                             │
│  (main.dart - Theme Configuration)                          │
│  - Primary Color: Indigo                                    │
│  - Rounded Corners: 16px                                    │
│  - Material3: Enabled                                       │
└──────────────┬──────────────────────────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
    ┌─────────┐   ┌──────────┐
    │HomePage │   │CameraPage│
    └────┬────┘   └────┬─────┘
         │             │
         │             ├─→ ImagePreviewPage
         │             │   (category selection)
         │             │
         │             └─→ CameraService
         │                 (business logic)
         │
         └─→ CameraService
             (cache management)

CameraService
├── requestCameraPermission()
├── isCameraPermissionGranted()
├── saveImageToCache()           ← Cache Logic Here
├── getCachedImages()
├── deleteImageFromCache()
├── clearCache()
└── extractCategoryFromFileName()
```

### Data Flow

```
User Action → Widget → Service → Native Platform → Result

Example - Take Photo:
User clicks shutter
    ↓
CameraPage._takePicture()
    ↓
_cameraController.takePicture()
    ↓
Native Android/iOS Camera API
    ↓
Image file returned
    ↓
Navigate to ImagePreviewPage
```

---

## 3. Code Explanation - Key Functions

### A. Permission Handling

**File: `lib/services/camera_service.dart`**

```dart
/// Request izin kamera dari user
Future<bool> requestCameraPermission() async {
  // Permission handler menampilkan dialog native
  final PermissionStatus status = await Permission.camera.request();
  
  // Cek status: granted, denied, restricted, permanentlyDenied
  return status.isGranted;
}
```

**How it works:**
- Saat dipanggil, user melihat dialog native Android/iOS
- User memilih "Allow" atau "Deny"
- Method return `true` jika granted, `false` sebaliknya

---

### B. Image Caching & Naming

**File: `lib/services/camera_service.dart`**

```dart
/// Simpan gambar ke cache dengan format: [kategori]_[timestamp].jpg
static Future<String?> saveImageToCache({
  required String sourceImagePath,
  required String kategori,
}) async {
  try {
    // 1. Dapatkan cache directory (temporary directory)
    final cacheDir = await getTemporaryDirectory();
    
    // 2. Format timestamp: yyyy-MM-dd-HH-mm-ss
    final timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss')
                      .format(DateTime.now());
    
    // 3. Buat nama file: Depan_2024-12-20-14-30-45.jpg
    final fileName = '${kategori}_$timestamp.jpg';
    
    // 4. Path lengkap di cache
    final filePath = '${cacheDir.path}/$fileName';
    
    // 5. Copy file dari sumber (temporary) ke cache
    final sourceFile = File(sourceImagePath);
    final cachedFile = await sourceFile.copy(filePath);
    
    // 6. Return path file yang sudah disimpan
    return cachedFile.path;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

**Alur Detail:**

```
1. sourceImagePath: "/data/user/0/com.example.geosurvey/cache/IMG_123.jpg"
   ↓
2. getTemporaryDirectory(): "/data/user/0/com.example.geosurvey/cache/"
   ↓
3. kategori: "Depan"
   ↓
4. timestamp: DateFormat('yyyy-MM-dd-HH-mm-ss')
              = "2024-12-20-14-30-45"
   ↓
5. fileName: "Depan_2024-12-20-14-30-45.jpg"
   ↓
6. filePath: "/data/user/0/com.example.geosurvey/cache/Depan_2024-12-20-14-30-45.jpg"
   ↓
7. File.copy(filePath)
   ↓
8. return: "/data/user/0/com.example.geosurvey/cache/Depan_2024-12-20-14-30-45.jpg"
```

---

### C. Camera Preview & Capture

**File: `lib/pages/camera_page.dart`**

```dart
/// Ambil foto menggunakan camera controller
Future<void> _takePicture() async {
  if (_cameraController == null || 
      !_cameraController!.value.isInitialized) {
    return; // Controller belum siap
  }

  if (_isTakingPhoto) return; // Prevent multiple rapid taps

  try {
    setState(() => _isTakingPhoto = true); // Show loading

    // Call native camera API untuk ambil foto
    final image = await _cameraController!.takePicture();

    if (mounted) {
      // Navigate ke preview page dengan path gambar
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
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _isTakingPhoto = false); // Hide loading
  }
}
```

**State Management:**
- `_isTakingPhoto`: Prevent multiple captures
- `setState()`: Trigger UI rebuild
- `mounted`: Check if widget still in tree before setState

---

### D. Category Selection & Save

**File: `lib/pages/image_preview_page.dart`**

```dart
/// Simpan gambar dengan kategori yang dipilih
Future<void> _saveImageWithCategory(String category) async {
  setState(() => _isLoading = true);

  try {
    // 1. Panggil service untuk simpan ke cache
    final savedPath = await CameraService.saveImageToCache(
      sourceImagePath: widget.imagePath,
      kategori: category,
    );

    if (mounted) {
      if (savedPath != null) {
        // 2. Success - Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto kategori "$category" telah disimpan'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // 3. Navigate back ke home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        // 2. Failed - Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan foto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

**Error Handling Pattern:**
```
try {
  ✓ Perform action
  ✓ Show success message
} catch (e) {
  ✗ Catch error
  ✗ Show error message
} finally {
  - Cleanup (stop loading, dispose)
}
```

---

## 4. Widget Tree

### HomePage Widget Tree

```
Scaffold
├── AppBar
│   └── Text("GeoSurvey")
└── SingleChildScrollView
    └── Column
        ├── Container (Header)
        │   └── Column
        │       ├── Icon (location_on)
        │       ├── Text (Title)
        │       └── Text (Subtitle)
        └── Padding
            └── Column
                ├── Text ("Ambil Foto")
                ├── Card (Camera Action)
                │   └── InkWell → _openCamera()
                ├── Text ("Foto Tersimpan")
                ├── Container (Stats)
                └── Container (Info)
```

### CameraPage Widget Tree

```
Scaffold
├── AppBar
├── Stack
│   ├── CameraPreview(_cameraController) ← Camera Live Feed
│   ├── Center → _buildGuideOverlay()    ← Guide Frame
│   ├── Positioned (Top)
│   │   ├── Flash Toggle Button
│   │   └── Camera Switch Button
│   └── Positioned (Bottom)
│       └── Shutter Button (circular)
```

### ImagePreviewPage Widget Tree

```
Scaffold
├── AppBar
└── Stack
    ├── Column
    │   └── Image.file(widget.imagePath)
    └── Positioned (Bottom)
        └── Container
            └── Row
                ├── OutlinedButton ("Ambil Ulang")
                └── ElevatedButton ("Gunakan Foto")
                    ↓
                    showModalBottomSheet()
                    └── GridView (4 Categories)
```

---

## 5. State Management Pattern

### Using setState() Pattern

```dart
class _CameraPageState extends State<CameraPage> {
  bool _isInitialized = false;
  bool _isTakingPhoto = false;
  FlashMode _flashMode = FlashMode.off;

  void _toggleFlash() {
    setState(() {
      // Update state → rebuild widget
      _flashMode = _flashMode == FlashMode.off 
                   ? FlashMode.on 
                   : FlashMode.off;
    });
    _cameraController?.setFlashMode(_flashMode);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild triggered by setState()
    return Scaffold(
      body: _isInitialized 
           ? CameraPreview(...)  // Camera ready
           : LoadingWidget(),    // Still loading
    );
  }
}
```

---

## 6. Error Handling Strategy

### Permission Errors

```dart
if (!hasPermission) {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Izin kamera diperlukan'))
  );
  // Go back
  Navigator.pop(context);
  return;
}
```

### Camera Init Errors

```dart
try {
  await controller.initialize();
} catch (e) {
  // Log error
  print('Error: $e');
  // Notify user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error init camera: $e'))
  );
}
```

### Cache Save Errors

```dart
final savedPath = await CameraService.saveImageToCache(...);

if (savedPath != null) {
  // Success
} else {
  // Failed - show error, path is null
}
```

---

## 7. Performance Considerations

### Image Handling

```
Original Camera Photo: ~5-10 MB
↓
CameraPreview displays full resolution (optimized by framework)
↓
takePicture() returns high quality image
↓
Copy to cache (full size - could be large)
↓
Consider compression for production:
  - Use image package
  - Reduce quality/resolution
  - Save to persistent storage (not just cache)
```

### Memory Management

```dart
@override
void dispose() {
  _cameraController?.dispose(); // Release native resources
  super.dispose();
}
```

---

## 8. Testing Checklist

✅ **Initialization**
- [ ] Permission dialog appears
- [ ] Camera preview loads
- [ ] Controls visible (flash, switch)

✅ **Camera Operations**
- [ ] Flash toggle works
- [ ] Camera switch works (if dual camera)
- [ ] Shutter button responds

✅ **Photo Workflow**
- [ ] Photo captured and saved temporarily
- [ ] Preview page displays correctly
- [ ] Retake button returns to camera
- [ ] Use photo button shows categories

✅ **Caching**
- [ ] Category selection works
- [ ] File saved with correct name format
- [ ] File saved in correct directory
- [ ] Home page shows updated count

✅ **Error Handling**
- [ ] Permission denial handled
- [ ] Camera not available handled
- [ ] Save failures handled gracefully

---

## 9. Future Enhancements

### Phase 2
- [ ] Image compression before cache
- [ ] Database to track metadata
- [ ] GPS location tagging
- [ ] Photo gallery view

### Phase 3
- [ ] Server upload integration
- [ ] Batch processing
- [ ] Offline sync
- [ ] Advanced filters
