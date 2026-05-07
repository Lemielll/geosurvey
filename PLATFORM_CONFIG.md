# Platform-Specific Configuration

## Android Configuration

### 1. AndroidManifest.xml Setup

**File: `android/app/src/main/AndroidManifest.xml`**

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.geosurvey">

    <!-- Camera Permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Storage Permissions (for Android 12 and below) -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of application config ... -->
    </application>
</manifest>
```

### 2. Build Gradle Configuration

**File: `android/app/build.gradle.kts`**

```kotlin
android {
    namespace = "com.example.geosurvey"
    compileSdk = 34  // Minimum 31 for camera package

    defaultConfig {
        applicationId = "com.example.geosurvey"
        minSdk = 21    // Minimum supported Android version
        targetSdk = 34 // Latest stable
        versionCode = 1
        versionName = "1.0.0"
    }

    // ... other configurations ...
}

dependencies {
    // Camera plugin dependency handled by Flutter
}
```

### 3. Runtime Permissions (Android 6+)

Android 6.0+ requires runtime permission requests. The `permission_handler` package handles this automatically.

**How it works:**
1. App defines permissions in AndroidManifest.xml
2. When camera is accessed, `permission_handler` shows permission dialog
3. User grants or denies permission
4. App reacts accordingly

**Testing Runtime Permissions:**

```bash
# Install app
flutter run

# When camera page opens:
# - Permission dialog appears
# - Select "Allow" or "Deny"
# - App responds accordingly
```

**Manual Permission Reset (for testing):**
```bash
# Clear app data and permissions
adb shell pm clear com.example.geosurvey

# Reinstall app
flutter run
```

### 4. Camera Feature Declaration (Optional)

**File: `android/app/src/main/AndroidManifest.xml`**

```xml
<uses-feature
    android:name="android.hardware.camera"
    android:required="true" />

<uses-feature
    android:name="android.hardware.camera.autofocus"
    android:required="false" />
```

- `required="true"`: App won't run on devices without camera
- `required="false"`: App runs on any device (graceful degradation)

---

## iOS Configuration

### 1. Info.plist Setup

**File: `ios/Runner/Info.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... existing configurations ... -->

    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>Aplikasi memerlukan akses kamera untuk mengambil foto surveyor geografis.</string>

    <!-- Photo Library Permissions (if needed for future) -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Aplikasi memerlukan akses ke galeri foto Anda.</string>

    <key>NSPhotoLibraryAddOnlyUsageDescription</key>
    <string>Aplikasi memerlukan izin untuk menyimpan foto ke galeri.</string>

    <!-- Microphone (set to NO since we disable audio) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Aplikasi tidak memerlukan akses ke mikrofon.</string>

    <!-- ... rest of configuration ... -->
</dict>
</plist>
```

### 2. Podfile Configuration

**File: `ios/Podfile`**

Biasanya sudah auto-generated, tapi pastikan:

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_root = File.expand_path(File.join(packages_path, 'flutter'))
  load File.join(flutter_root, 'packages', 'flutter_tools', 'bin', 'podhelper')

  flutter_ios_podfile_setup

  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

### 3. Deployment Target

**File: `ios/Podfile`**

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### 4. Build Settings

**File: `ios/Runner.xcodeproj/project.pbxproj`**

Usually handled by Flutter, but can verify in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Select Runner target
4. Build Settings tab
5. Search "IPHONEOS_DEPLOYMENT_TARGET" → set to 12.0 or higher

---

## Permission Handler Configuration

The app uses `permission_handler` to manage runtime permissions.

### Request Flow

```dart
// In CameraService.requestCameraPermission()
final PermissionStatus status = await Permission.camera.request();

// Returns: granted, denied, restricted, or permanentlyDenied
if (status.isGranted) {
  // Can use camera
} else if (status.isDenied) {
  // User denied - can request again
} else if (status.isPermanentlyDenied) {
  // User denied permanently - open app settings
  openAppSettings();
}
```

### Handling Permanently Denied

If user taps "Don't Allow" twice, permission is permanently denied.

**Solution:**
```dart
if (status.isPermanentlyDenied) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Izin Kamera Diperlukan'),
      content: Text('Silakan buka Settings > Permissions dan aktifkan Camera'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Buka Settings'),
        ),
      ],
    ),
  );
}
```

---

## Testing Permissions

### Android

**Test with ADB:**
```bash
# Revoke all permissions
adb shell pm revoke com.example.geosurvey android.permission.CAMERA

# Grant permission
adb shell pm grant com.example.geosurvey android.permission.CAMERA

# Check permission status
adb shell pm list permissions -u
```

**In App:**
1. Navigate to Camera page
2. Permission dialog should appear
3. Grant/deny and verify behavior

### iOS

**Using Xcode:**
1. Open ios/Runner.xcworkspace in Xcode
2. Run on simulator or device
3. When camera is accessed:
   - Simulator: May not have real camera, but permission dialog appears
   - Device: Permission dialog appears
4. Grant/deny and test behavior

**Reset Permissions:**
```bash
# On simulator
xcrun simctl erase all

# On device
Settings > [App Name] > Camera > Off/On
```

---

## Troubleshooting Platform Issues

### Android: Camera black screen

**Causes:**
- Permission denied
- Camera controller not initialized
- Surface texture issue

**Solutions:**
1. Check Android Manifest for CAMERA permission
2. Verify permission is granted in Settings
3. Restart app
4. Try different camera (front/back)

### iOS: Permission dialog not showing

**Causes:**
- NSCameraUsageDescription missing in Info.plist
- Invalid XML syntax in plist
- App needs to be reinstalled

**Solutions:**
1. Verify Info.plist has NSCameraUsageDescription
2. Validate plist XML (Open with Xcode)
3. Clean build: `flutter clean`
4. Rebuild: `flutter run`

### Both: App crashes on camera init

**Causes:**
- Incompatible camera package version
- Pod installation issues (iOS)
- Gradle sync problems (Android)

**Solutions:**
```bash
flutter clean
flutter pub get
flutter run --verbose  # See detailed error logs

# For iOS
cd ios && rm -rf Pods Podfile.lock
pod install
cd ..
```

---

## Best Practices

✅ **DO:**
- Always request permission before accessing camera
- Handle all permission statuses (granted, denied, restricted, permanently denied)
- Show user-friendly messages for permission denials
- Test on real devices
- Verify permissions in app settings after testing

❌ **DON'T:**
- Assume permission is always granted
- Ignore permission request responses
- Forget to add permissions to manifest/plist
- Test only on simulators (they have limitations)
- Hard-code permission strings

---

## References

- Camera package: https://pub.dev/packages/camera
- Permission Handler: https://pub.dev/packages/permission_handler
- Android Permissions: https://developer.android.com/training/permissions
- iOS Permissions: https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
- Flutter Platform Channels: https://flutter.dev/docs/development/platform-integration
