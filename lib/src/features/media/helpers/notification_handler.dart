// Enum cho các loại thông báo
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

enum NotificationType { error, success, permission }

// Handler thông báo thông minh tập trung vào trải nghiệm người dùng
class SmartNotificationHandler {
  final BuildContext context;
  final Logger _logger = Logger('SmartNotificationHandler');

  // Biến để kiểm soát số lần hiển thị thông báo
  bool _hasShownCameraPermissionInfo = false;
  bool _hasShownGalleryPermissionInfo = false;
  DateTime? _lastErrorNotificationTime;

  SmartNotificationHandler(this.context);

  void handleNotification(
    NotificationType type,
    String message, {
    dynamic data,
  }) {
    switch (type) {
      case NotificationType.error:
        _handleErrorNotification(message, data);
        break;
      case NotificationType.success:
        // Chỉ hiển thị thông báo thành công khi thực sự cần thiết
        // Bỏ qua các thông báo thành công thông thường để không làm phiền người dùng
        _logger.info(message);
        break;
      case NotificationType.permission:
        // Được xử lý trong requestPermission
        break;
    }
  }

  // Xử lý thông báo lỗi thông minh
  void _handleErrorNotification(String message, dynamic data) {
    _logger.warning(message);

    // Tránh hiển thị nhiều thông báo lỗi trong khoảng thời gian ngắn
    final now = DateTime.now();
    if (_lastErrorNotificationTime != null) {
      final difference = now.difference(_lastErrorNotificationTime!);
      if (difference.inSeconds < 3) {
        return; // Bỏ qua nếu thông báo lỗi quá gần nhau
      }
    }

    // Kiểm tra xem đây có phải lỗi quyền không
    if (data is Exception && message.contains('permission')) {
      _handlePermissionError(message);
    } else {
      // Với các lỗi khác, hiển thị thông báo ngắn gọn
      _showSnackBar(message, Colors.red);
    }

    _lastErrorNotificationTime = now;
  }

  // Xử lý lỗi quyền thông minh
  void _handlePermissionError(String message) {
    // Nếu lỗi liên quan đến Camera
    if (message.contains('Camera')) {
      if (!_hasShownCameraPermissionInfo) {
        _showPermissionErrorDialog(
          'Ứng dụng cần quyền truy cập Camera',
          'Bạn có thể cấp quyền trong Cài đặt của thiết bị.',
        );
        _hasShownCameraPermissionInfo = true;
      }
    }
    // Nếu lỗi liên quan đến Gallery/Storage
    else if (message.contains('storage') ||
        message.contains('photo') ||
        message.contains('image')) {
      if (!_hasShownGalleryPermissionInfo) {
        _showPermissionErrorDialog(
          'Ứng dụng cần quyền truy cập Thư viện ảnh',
          'Bạn có thể cấp quyền trong Cài đặt của thiết bị.',
        );
        _hasShownGalleryPermissionInfo = true;
      }
    } else {
      // Các lỗi quyền khác
      _showSnackBar(message, Colors.red);
    }
  }

  // Hiển thị dialog hướng dẫn cấp quyền
  void _showPermissionErrorDialog(String title, String content) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Mở Cài đặt'),
                ),
              ],
            ),
      );
    }
  }

  Future<bool> requestPermission(Permission permission, String message) async {
    // Kiểm tra trạng thái quyền hiện tại
    final status = await permission.status;

    // Nếu đã được cấp quyền, không cần hỏi lại
    if (status.isGranted) {
      return true;
    }

    // Kiểm tra nếu context vẫn hợp lệ (mounted)
    if (!context.mounted) {
      return false;
    }

    // Nếu đã bị từ chối vĩnh viễn, hiển thị dialog gợi ý vào Settings
    if (status.isPermanentlyDenied) {
      final permissionName = _getPermissionName(permission);
      return await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Cần quyền $permissionName'),
                  content: Text(
                    '$message\n\nBạn đã từ chối quyền này trước đó. Vui lòng vào Cài đặt để cấp quyền thủ công.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.pop(context, false);
                      },
                      child: const Text('Mở Cài đặt'),
                    ),
                  ],
                ),
          ) ??
          false;
    }

    // Kiểm tra lại trạng thái mounted
    if (!context.mounted) {
      return false;
    }

    // Thay thế isUndetermined - kiểm tra trạng thái isDenied, lúc này là trạng thái
    if (status.isDenied) {
      final permissionName = _getPermissionName(permission);
      final shouldRequest =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Cấp quyền $permissionName'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getPermissionIcon(permission),
                      const SizedBox(height: 16),
                      Text(message),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Không, cảm ơn'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đồng ý'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldRequest && context.mounted) {
        final result = await permission.request();
        return result.isGranted;
      }
      return false;
    }

    // Kiểm tra lại trạng thái mounted
    if (!context.mounted) {
      return false;
    }

    // Các trạng thái khác (hiếm gặp: restricted, limited, etc.)
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Cần quyền truy cập'),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Từ chối'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Đồng ý'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Helper để lấy tên thân thiện của quyền
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.photos:
        return 'Thư viện ảnh';
      case Permission.storage:
        return 'Bộ nhớ';
      case Permission.microphone:
        return 'Microphone';
      default:
        return 'truy cập';
    }
  }

  // Helper để lấy icon phù hợp với loại quyền
  Widget _getPermissionIcon(Permission permission) {
    IconData iconData;
    Color iconColor;

    switch (permission) {
      case Permission.camera:
        iconData = Icons.camera_alt;
        iconColor = Colors.blue;
        break;
      case Permission.photos:
        iconData = Icons.photo_library;
        iconColor = Colors.green;
        break;
      case Permission.storage:
        iconData = Icons.folder;
        iconColor = Colors.orange;
        break;
      case Permission.microphone:
        iconData = Icons.mic;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.security;
        iconColor = Colors.grey;
    }

    return Icon(iconData, size: 48, color: iconColor);
  }

  // Phương thức helper để hiển thị SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
