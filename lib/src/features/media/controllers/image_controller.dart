import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import '../helpers/notification_handler.dart';
import '../models/image_item.dart';

/// Lớp tùy chọn cho việc chọn ảnh
class ImageOptions {
  final ImageSource source;
  final bool allowMultiple;
  final int? imageQuality;
  final double? maxWidth;
  final double? maxHeight;

  const ImageOptions({
    required this.source,
    this.allowMultiple = false,
    this.imageQuality,
    this.maxWidth,
    this.maxHeight,
  });
}

/// Controller để quản lý việc chọn ảnh và cắt ảnh
class ImageController {
  final SmartNotificationHandler notificationHandler;
  final ImagePicker _picker = ImagePicker();
  final ImageCropper _cropper = ImageCropper();
  final Logger _logger = Logger('ImageController');

  ImageController({required this.notificationHandler});

  static void setupLogging({Level logLevel = Level.INFO}) {
    Logger.root.level = logLevel;
    Logger.root.onRecord.listen((record) {
      // Sử dụng logger thay vì print trong production
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<List<ImageItem>> pickImages(ImageOptions options) async {
    try {
      // Kiểm tra và yêu cầu quyền truy cập
      bool hasPermission = false;

      if (options.source == ImageSource.camera) {
        hasPermission = await notificationHandler.requestPermission(
          Permission.camera,
          'Ứng dụng cần quyền truy cập Camera để chụp ảnh.',
        );
      } else {
        hasPermission = await notificationHandler.requestPermission(
          Permission.photos,
          'Ứng dụng cần quyền truy cập Thư viện ảnh để chọn ảnh.',
        );
      }

      if (!hasPermission) {
        notificationHandler.handleNotification(
          NotificationType.error,
          'Không thể truy cập ${options.source == ImageSource.camera ? 'Camera' : 'Thư viện ảnh'}',
          data: Exception('Permission denied'),
        );
        return [];
      }

      List<XFile>? pickedFiles;

      if (options.source == ImageSource.camera) {
        // Chụp ảnh từ camera
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: options.imageQuality,
          maxWidth: options.maxWidth,
          maxHeight: options.maxHeight,
        );

        if (photo != null) {
          pickedFiles = [photo];
        }
      } else {
        // Chọn từ gallery
        if (options.allowMultiple) {
          pickedFiles = await _picker.pickMultiImage(
            imageQuality: options.imageQuality,
            maxWidth: options.maxWidth,
            maxHeight: options.maxHeight,
          );
        } else {
          final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: options.imageQuality,
            maxWidth: options.maxWidth,
            maxHeight: options.maxHeight,
          );

          if (image != null) {
            pickedFiles = [image];
          }
        }
      }

      if (pickedFiles == null || pickedFiles.isEmpty) {
        _logger.info('Không có ảnh nào được chọn');
        return [];
      }

      // Chuyển đổi XFile sang ImageItem
      List<ImageItem> result = [];
      for (var xFile in pickedFiles) {
        result.add(
          ImageItem(file: File(xFile.path), path: xFile.path, name: xFile.name),
        );
      }

      if (result.isNotEmpty) {
        notificationHandler.handleNotification(
          NotificationType.success,
          'Đã chọn ${result.length} ảnh',
        );
      }

      return result;
    } catch (e) {
      _logger.severe('Lỗi khi chọn ảnh: $e');
      notificationHandler.handleNotification(
        NotificationType.error,
        'Đã xảy ra lỗi khi chọn ảnh: ${e.toString()}',
        data: e,
      );
      return [];
    }
  }

  /// Phương thức mới để cắt ảnh
  Future<ImageItem?> cropImage(
    BuildContext context,
    ImageItem sourceImage,
  ) async {
    try {
      CroppedFile? croppedFile = await _cropper.cropImage(
        sourcePath: sourceImage.file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Chỉnh sửa ảnh',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Theme.of(context).primaryColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Chỉnh sửa ảnh',
            doneButtonTitle: 'Xong',
            cancelButtonTitle: 'Hủy',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioLockEnabled: false,
          ),
        ],
        compressQuality: 90,
      );

      if (croppedFile == null) {
        _logger.info('Người dùng đã hủy việc cắt ảnh');
        return null;
      }

      // Tạo ImageItem mới từ ảnh đã cắt
      final croppedImageItem = ImageItem(
        file: File(croppedFile.path),
        path: croppedFile.path,
        name: sourceImage.name,
      );

      notificationHandler.handleNotification(
        NotificationType.success,
        'Đã chỉnh sửa ảnh thành công',
      );

      return croppedImageItem;
    } catch (e) {
      _logger.severe('Lỗi khi cắt ảnh: $e');
      notificationHandler.handleNotification(
        NotificationType.error,
        'Đã xảy ra lỗi khi chỉnh sửa ảnh: ${e.toString()}',
        data: e,
      );
      return null;
    }
  }
}
