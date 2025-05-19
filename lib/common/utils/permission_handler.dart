import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  static bool _isRequestingPermission = false;

  static Future<bool> requestPermissions(List<Permission> permissions) async {
    if (_isRequestingPermission) {
      return false;
    }

    try {
      _isRequestingPermission = true;
      
      // Request all permissions at once
      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      return allGranted;
    } finally {
      _isRequestingPermission = false;
    }
  }

  static Future<bool> requestCameraAndMicrophone() async {
    return requestPermissions([Permission.camera, Permission.microphone]);
  }

  static Future<bool> requestStorage() async {
    return requestPermissions([Permission.storage, Permission.photos]);
  }

  static Future<bool> requestNotification() async {
    return requestPermissions([Permission.notification]);
  }

  static Future<bool> checkPermission(Permission permission) async {
    return await permission.isGranted;
  }
} 