// Lightweight file descriptor for multi-file order flow
class FileItem {
  final String path;
  final String name;
  final int size;
  final String? extension;
  final int pageCount;

  FileItem({
    required this.path,
    required this.name,
    this.size = 0,
    this.extension,
    this.pageCount = 0,
  });

  factory FileItem.fromPath(String path, String name, {int size = 0}) {
    final parts = name.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : null;
    return FileItem(
      path: path,
      name: name,
      size: size,
      extension: ext,
    );
  }

  bool get isPdf => extension == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  bool get isOffice => ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension);

  // TODO: add file size validation before upload
  String get icon {
    if (isPdf) return '\u{1F4C4}';
    if (isImage) return '\u{1F5BC}';
    if (isOffice) return '\u{1F4DD}';
    return '\u{1F4C1}';
  }

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
