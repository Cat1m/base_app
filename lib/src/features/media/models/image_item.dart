import 'dart:io';

class ImageItem {
  final File file;
  final String? path;
  final String? name;
  final DateTime dateAdded;

  ImageItem({required this.file, this.path, this.name, DateTime? dateAdded})
    : dateAdded = dateAdded ?? DateTime.now();
}
