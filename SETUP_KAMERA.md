# Fitur Kamera GeoSurvey - Panduan Setup

## Daftar Dependencies

Berikut packages yang telah ditambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  camera: ^0.10.8+1           # Akses kamera perangkat
  path_provider: ^2.1.1       # Dapatkan cache directory
  permission_handler: ^11.4.4 # Manajemen izin akses
  intl: ^0.19.0              # Format timestamp
```

## Instalasi

1. **Update dependencies:**
   ```bash
   flutter pub get
   ```

2. **Clean build:**
   ```bash
   flutter clean
   ```

## Konfigurasi Platform

### Android

**File: `android/app/src/main/AndroidManifest.xml`**

Tambahkan permissions di dalam tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**File: `android/app/build.gradle.kts`**

Pastikan `compileSdk` minimal 31:
```kotlin
android {
    compileSdk = 34 // atau lebih tinggi
    ...
}
```

### iOS

**File: `ios/Runner/Info.plist`**

Tambahkan permission descriptions:

```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk mengambil foto surveyor</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses ke galeri foto</string>

<key>NSPhotoLibraryAddOnlyUsageDescription</key>
<string>Aplikasi memerlukan izin menyimpan foto</string>
```

**Verifikasi iOS build:**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

## Struktur Kode

### 1. Service Layer - `lib/services/camera_service.dart`

Menangani:
- Permission handling
- Penyimpanan gambar ke cache lokal dengan format: `[Kategori]_[timestamp].jpg`
- Retrieval dan deletion gambar dari cache
- Ekstrak kategori dari nama file

**Fungsi Utama:**
```dart
// Request izin kamera
Future<bool> requestCameraPermission()

// Simpan gambar ke cache dengan kategori
Future<String?> saveImageToCache({
  required String sourceImagePath,
  required String kategori,
})

// Dapatkan daftar gambar tersimpan
Future<List<File>> getCachedImages()

// Hapus gambar tertentu
Future<bool> deleteImageFromCache(String filePath)

// Hapus semua gambar
Future<bool> clearCache()
```

### 2. UI Layer - Camera Page

**File: `lib/pages/camera_page.dart`**

Fitur:
- Full-screen camera preview
- Overlay bingkai panduan di tengah layar
- Tombol shutter estetis (circular button, indigo color)
- Kontrol flash (on/off) - top left
- Switch camera (depan/belakang) - top right
- Error handling & loading states

**Workflow:**
1. Request permission saat initialization
2. Setup camera controller dengan high resolution
3. Tampilkan preview dengan overlay
4. Ambil foto dengan CameraController.takePicture()
5. Navigate ke preview page

### 3. UI Layer - Image Preview

**File: `lib/pages/image_preview_page.dart`**

Fitur:
- Tampilkan preview gambar full-size
- Dua opsi tombol:
  - **Ambil Ulang**: Kembali ke kamera
  - **Gunakan Foto**: Buka category selection

**Category Selection Bottom Sheet:**
- Empat kategori dengan icon:
  - 🔽 Depan (Front)
  - ➡️ Kanan (Right)
  - ⬅️ Kiri (Left)
  - 🔼 Belakang (Back)
  
- Saat kategori dipilih, gambar disimpan ke cache dengan nama: `[Kategori]_[timestamp].jpg`
- Notifikasi sukses/error

### 4. Home Page Updates

**File: `lib/pages/home_page.dart`**

Diupdate dengan:
- Modern material design UI
- Action card untuk membuka kamera
- Display statistik foto tersimpan
- Opsi untuk hapus semua foto dengan confirmation dialog
- Info section dengan format penamaan file

## Theme Configuration

**File: `lib/main.dart`**

Konfigurasi theme:
- Primary Color: **Indigo**
- Material3: Enabled
- Rounded Corners: **16px** (AppBar, Buttons, Input, Cards)
- Typography: Modern dengan weights yang konsisten

## Format Penamaan File

Gambar disimpan dengan format:

```
[Kategori]_[YYYY-MM-DD-HH-mm-ss].jpg
```

**Contoh:**
- `Depan_2024-12-20-14-30-45.jpg`
- `Kanan_2024-12-20-14-31-12.jpg`
- `Kiri_2024-12-20-14-31-58.jpg`
- `Belakang_2024-12-20-14-32-05.jpg`

## Penyimpanan Data

Gambar disimpan di:
```
Temporary Directory (Cache)
- Android: `/data/user/0/com.example.geosurvey/cache/`
- iOS: `NSTemporaryDirectory()`
```

**Catatan:** Cache directory bersifat temporary dan bisa dihapus oleh sistem. Untuk penyimpanan permanen, gunakan `getApplicationDocumentsDirectory()` dari path_provider.

## Testing

### Test di Android Emulator

```bash
# Buka app
flutter run

# Test camera permission
# Buka halaman camera - akan muncul permission dialog

# Test camera functionality
# - Ambil foto
# - Lihat preview
# - Pilih kategori
# - Verifikasi file tersimpan
```

### Test di iOS Simulator

```bash
flutter run -d "iPhone 15"
```

**Catatan:** iOS Simulator mungkin tidak memiliki kamera fisik, gunakan device asli untuk test lengkap.

## Troubleshooting

### ❌ Permission Denied
**Solusi:**
- Buka Android Settings > Apps > GeoSurvey > Permissions > Camera > Allow
- iOS: Settings > GeoSurvey > Camera > Allow

### ❌ "Tidak ada kamera tersedia"
**Solusi:**
- Gunakan device asli (bukan simulator)
- Restart aplikasi
- Cek AndroidManifest.xml untuk permissions

### ❌ Gambar tidak muncul setelah disimpan
**Solusi:**
- Verifikasi path_provider dapat mengakses cache directory
- Cek permission WRITE_EXTERNAL_STORAGE di Android
- Gunakan `CameraService.getCachedImages()` untuk list semua file

### ❌ Camera preview tidak menampil
**Solusi:**
- Pastikan CameraController sudah initialized
- Cek `_isInitialized` state
- Verifikasi permission sudah granted

## Fitur Lanjutan (Optional)

### Tambahan Implementasi:

1. **Compress Gambar**
   - Gunakan package `image` untuk compress
   - Reduce file size sebelum save

2. **Upload ke Server**
   - Tambahkan logic untuk upload gambar
   - Gunakan `http` atau `dio` package

3. **Database Lokal**
   - Gunakan `sqflite` untuk track metadata
   - Store kategori, timestamp, lokasi GPS, etc.

4. **Preview Galeri**
   - Tampilkan thumbnail semua foto tersimpan
   - Fitur delete individual photo

## Bahasa & Lokalisasi

Semua teks UI sudah dalam **Bahasa Indonesia**:
- ✅ Labels: "Ambil Ulang", "Gunakan Foto", "Posisikan Objek"
- ✅ Messages: "Izin akses kamera diperlukan", "Foto telah disimpan"
- ✅ Category names: "Depan", "Kanan", "Kiri", "Belakang"

## Summary

Fitur kamera GeoSurvey sudah lengkap dengan:
- ✅ Modern UI dengan Material3
- ✅ Full camera workflow (take → preview → categorize → save)
- ✅ Permission handling
- ✅ Cache management
- ✅ Indonesian localization
- ✅ Error handling & user feedback
- ✅ Loading states & animations

Siap untuk production atau development lanjutan!
