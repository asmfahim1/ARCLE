import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class PermissionService {
  bool get _isWeb => kIsWeb;
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  bool get supportsNotifications => !_isWeb && (_isAndroid || _isIOS || _isMacOS);
  bool get supportsStoragePermission => !_isWeb && _isAndroid;
  bool get supportsPhotosPermission => !_isWeb && (_isIOS || _isMacOS);

  // Camera permissions
  Future<bool> hasCamera() async {
    if (_isWeb) return false;
    return Permission.camera.isGranted;
  }
  
  Future<bool> requestCamera() async {
    if (_isWeb) return false;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Notification permissions
  Future<bool> hasNotifications() async {
    if (!supportsNotifications) return false;
    return Permission.notification.isGranted;
  }
  
  Future<bool> requestNotifications() async {
    if (!supportsNotifications) return false;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Storage permissions
  Future<bool> hasStorage() async {
    if (supportsStoragePermission) {
      return Permission.storage.isGranted;
    }
    if (supportsPhotosPermission) {
      return hasPhotos();
    }
    return false;
  }
  
  Future<bool> requestStorage() async {
    if (supportsPhotosPermission) {
      return requestPhotos();
    }
    if (!supportsStoragePermission) return false;

    final status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      return false;
    }
    return status.isGranted;
  }

  // Location permissions
  Future<bool> hasLocation() async {
    if (_isWeb) return false;
    return Permission.locationWhenInUse.isGranted;
  }
  
  Future<bool> requestLocation() async {
    if (_isWeb) return false;
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  // Microphone permissions
  Future<bool> hasMicrophone() async {
    if (_isWeb) return false;
    return Permission.microphone.isGranted;
  }
  
  Future<bool> requestMicrophone() async {
    if (_isWeb) return false;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Photos/Gallery permissions
  Future<bool> hasPhotos() async {
    if (!supportsPhotosPermission) return false;
    return Permission.photos.isGranted;
  }
  
  Future<bool> requestPhotos() async {
    if (!supportsPhotosPermission) return false;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Request multiple permissions at once
  Future<Map<Permission, bool>> requestMultiple(List<Permission> permissions) async {
    if (_isWeb) {
      return {
        for (final permission in permissions) permission: false,
      };
    }
    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }

  // Open app settings (when permission permanently denied)
  Future<bool> openSettings() => openAppSettings();
  
  // Permission status check
  Future<PermissionStatus> checkStatus(Permission permission) => permission.status;
}
