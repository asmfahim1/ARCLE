import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';


@lazySingleton

class PermissionService {
  // Camera permissions
  Future<bool> hasCamera() => Permission.camera.isGranted;
  
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Notification permissions
  Future<bool> hasNotifications() => Permission.notification.isGranted;
  
  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Storage permissions
  Future<bool> hasStorage() => Permission.storage.isGranted;
  
  Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      return false;
    }
    return status.isGranted;
  }

  // Location permissions
  Future<bool> hasLocation() => Permission.location.isGranted;
  
  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  // Microphone permissions
  Future<bool> hasMicrophone() => Permission.microphone.isGranted;
  
  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Photos/Gallery permissions
  Future<bool> hasPhotos() => Permission.photos.isGranted;
  
  Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Request multiple permissions at once
  Future<Map<Permission, bool>> requestMultiple(List<Permission> permissions) async {
    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }

  // Open app settings (when permission permanently denied)
  Future<bool> openSettings() => openAppSettings();
  
  // Permission status check
  Future<PermissionStatus> checkStatus(Permission permission) => permission.status;
}
