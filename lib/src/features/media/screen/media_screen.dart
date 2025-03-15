import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:media_module/media_module.dart';
import 'package:permission_handler/permission_handler.dart';

// Handler thông báo thông minh tập trung vào trải nghiệm người dùng
class SmartMediaNotificationHandler implements MediaNotificationHandler {
  final BuildContext context;
  final Logger _logger = Logger('SmartMediaNotificationHandler');

  // Biến để kiểm soát số lần hiển thị thông báo
  bool _hasShownCameraPermissionInfo = false;
  bool _hasShownGalleryPermissionInfo = false;
  DateTime? _lastErrorNotificationTime;

  SmartMediaNotificationHandler(this.context);

  @override
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
    if (data is MediaPermissionException) {
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

  @override
  // Trong class SmartMediaNotificationHandler hoặc bất kỳ class nào đang sử dụng PermissionStatus
  @override
  Future<bool> requestPermission(Permission permission, String message) async {
    // Kiểm tra trạng thái quyền hiện tại
    final status = await permission.status;

    // Nếu đã được cấp quyền, không cần hỏi lại
    if (status.isGranted) {
      return true;
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

      return shouldRequest;
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

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late MediaController _mediaController;
  final List<MediaItem> _selectedMedia = [];
  bool _isLoading = false;

  // Kiểm soát trạng thái các nút
  bool _disableGalleryButton = false;
  bool _disableCameraButton = false;

  @override
  void initState() {
    super.initState();
    // Cấu hình logging, chỉ ghi log lỗi và warning trong production
    MediaController.setupLogging(logLevel: Level.WARNING);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo controller với context hiện tại để có thể hiển thị UI
    _mediaController = MediaController(
      notificationHandler: SmartMediaNotificationHandler(context),
    );

    // Kiểm tra trạng thái quyền khi màn hình được tạo
    _checkInitialPermissions();
  }

  // Kiểm tra quyền ban đầu để cập nhật UI
  Future<void> _checkInitialPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await _getStoragePermissionStatus();

    setState(() {
      // Nếu quyền bị từ chối vĩnh viễn, disable nút tương ứng
      _disableCameraButton = cameraStatus.isPermanentlyDenied;
      _disableGalleryButton = storageStatus.isPermanentlyDenied;
    });
  }

  // Helper để lấy quyền storage phù hợp với phiên bản Android
  Future<PermissionStatus> _getStoragePermissionStatus() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Kiểm tra phiên bản Android (có thể làm trong MediaController)
      return await Permission.photos.status;
    } else {
      return await Permission.photos.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện Media'),
        actions: [
          if (_selectedMedia.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearSelectedMedia,
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Controls section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_buildGalleryButton(), _buildCameraButton()],
                ),
              ),

              // Media grid
              Expanded(
                child:
                    _selectedMedia.isEmpty
                        ? _buildEmptyState()
                        : _buildMediaGrid(),
              ),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có ảnh nào được chọn',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Sử dụng nút Gallery hoặc Camera để thêm ảnh',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.photo_library),
      label: const Text('Thư viện'),
      onPressed: _disableGalleryButton ? null : _pickFromGallery,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildCameraButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.camera_alt),
      label: const Text('Camera'),
      onPressed: _disableCameraButton ? null : _pickFromCamera,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedMedia.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media preview
              GestureDetector(
                onTap: () => _handleMediaTap(index),
                child: MediaPreview(
                  mediaItem: _selectedMedia[index],
                  borderRadius: BorderRadius.circular(0),
                  fit: BoxFit.cover,
                ),
              ),

              // Delete button
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedMedia.removeAt(index);
                      });
                    },
                  ),
                ),
              ),

              // Edit indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 12, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Sửa',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final media = await _mediaController.pickMedia(
        const MediaOptions(
          source: MediaSource.gallery,
          allowMultiple: true,
          imageQuality: 80,
        ),
      );

      if (media.isNotEmpty && mounted) {
        setState(() {
          _selectedMedia.addAll(media);
        });
      }
    } catch (e) {
      // Không cần xử lý lỗi ở đây vì NotificationHandler đã xử lý
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Cập nhật trạng thái nút sau khi thao tác
        _updateButtonStates();
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final media = await _mediaController.pickMedia(
        MediaOptions(
          source: MediaSource.camera,
          imageQuality: 90,
          cropOptions: const CropOptions(
            aspectRatio: CropAspectRatio.square,
            uiOptions: CropUIOptions(
              toolbarTitle: 'Chỉnh sửa ảnh',
              showCropGrid: true,
              hideBottomControls: false,
              cropFrameColor: Colors.white,
            ),
          ),
        ),
      );

      if (media.isNotEmpty && mounted) {
        setState(() {
          _selectedMedia.addAll(media);
        });
      }
    } catch (e) {
      // Không cần xử lý lỗi ở đây vì NotificationHandler đã xử lý
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Cập nhật trạng thái nút sau khi thao tác
        _updateButtonStates();
      }
    }
  }

  // Cập nhật trạng thái các nút dựa trên quyền hiện tại
  Future<void> _updateButtonStates() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await _getStoragePermissionStatus();

    if (mounted) {
      setState(() {
        _disableCameraButton = cameraStatus.isPermanentlyDenied;
        _disableGalleryButton = storageStatus.isPermanentlyDenied;
      });
    }
  }

  Future<void> _handleMediaTap(int index) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final croppedImage = await _mediaController.cropImage(
        _selectedMedia[index],
        const CropOptions(
          aspectRatio: CropAspectRatio.square,
          uiOptions: CropUIOptions(
            toolbarTitle: 'Chỉnh sửa ảnh',
            showCropGrid: true,
            hideBottomControls: false,
            cropFrameColor: Colors.white,
          ),
        ),
      );

      if (croppedImage != null && mounted) {
        setState(() {
          _selectedMedia[index] = croppedImage;
        });
      }
    } catch (e) {
      // Không cần xử lý lỗi ở đây vì NotificationHandler đã xử lý
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSelectedMedia() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa tất cả ảnh đã chọn?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedMedia.clear();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
    );
  }
}
