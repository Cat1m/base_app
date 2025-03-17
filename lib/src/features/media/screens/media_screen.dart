import 'package:base_app/src/features/media/helpers/notification_handler.dart';
import 'package:base_app/src/features/media/media.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late ImageController _imageController;
  final List<ImageItem> _selectedImages = [];
  bool _isLoading = false;

  // Kiểm soát trạng thái các nút
  bool _disableGalleryButton = false;
  bool _disableCameraButton = false;

  @override
  void initState() {
    super.initState();
    // Cấu hình logging, chỉ ghi log lỗi và warning trong production
    ImageController.setupLogging(logLevel: Level.WARNING);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo controller với context hiện tại để có thể hiển thị UI
    _imageController = ImageController(
      notificationHandler: SmartNotificationHandler(context),
    );

    // Kiểm tra trạng thái quyền khi màn hình được tạo
    _checkInitialPermissions();
  }

  // Kiểm tra quyền ban đầu để cập nhật UI
  Future<void> _checkInitialPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await _getStoragePermissionStatus();

    if (mounted) {
      setState(() {
        // Nếu quyền bị từ chối vĩnh viễn, disable nút tương ứng
        _disableCameraButton = cameraStatus.isPermanentlyDenied;
        _disableGalleryButton = storageStatus.isPermanentlyDenied;
      });
    }
  }

  // Helper để lấy quyền storage phù hợp với phiên bản Android
  Future<PermissionStatus> _getStoragePermissionStatus() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Kiểm tra phiên bản Android
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
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearSelectedImages,
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
                    _selectedImages.isEmpty
                        ? _buildEmptyState()
                        : _buildMediaGrid(),
              ),
            ],
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(77), // 0.3 opacity
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
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media preview
              ImagePreview(
                imageItem: _selectedImages[index],
                borderRadius: BorderRadius.circular(0),
                fit: BoxFit.cover,
              ),

              // Delete button
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128), // 0.5 opacity
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
                        _selectedImages.removeAt(index);
                      });
                    },
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

      final images = await _imageController.pickImages(
        ImageOptions(
          source: ImageSource.gallery,
          allowMultiple: true,
          imageQuality: 80,
        ),
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images);
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

      final images = await _imageController.pickImages(
        ImageOptions(source: ImageSource.camera, imageQuality: 90),
      );

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedImages.addAll(images);
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

  void _clearSelectedImages() {
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
                    _selectedImages.clear();
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
