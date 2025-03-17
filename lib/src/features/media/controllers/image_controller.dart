import 'dart:io';

import 'package:base_app/src/features/media/helpers/notification_handler.dart';
import 'package:base_app/src/features/media/media.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageController {
  final SmartNotificationHandler notificationHandler;
  final ImagePicker _picker = ImagePicker();
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
}

// Lớp tùy chọn cho việc chọn ảnh
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
