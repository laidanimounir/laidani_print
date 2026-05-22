import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../utils/helpers.dart';

class PickedFile {
  final String path;
  final String name;
  final int size;

  PickedFile({required this.path, required this.name, required this.size});
}

class FilePickerZone extends StatelessWidget {
  final List<PickedFile> files;
  final ValueChanged<List<PickedFile>> onFilesPicked;
  final VoidCallback? onRemoveFile;
  final int maxFiles;
  final bool loading;

  const FilePickerZone({
    super.key,
    required this.files,
    required this.onFilesPicked,
    this.onRemoveFile,
    this.maxFiles = 10,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drop zone
        if (files.length < maxFiles)
          GestureDetector(
            onTap: loading ? null : _pickFiles,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: files.isNotEmpty ? AppColors.success : AppColors.border,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.gray,
              ),
              child: Column(
                children: [
                  Text(
                    loading ? '\u{23F3}' : '\u{1F4C1}',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loading ? 'جاري الرفع...' : 'اسحب ملفك أو اضغط للاختيار',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, JPG, PNG, DOCX, XLSX, PPTX',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  if (files.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${files.length}/$maxFiles ملفات',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // TODO: show PDF page count after file selected
        // File list
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(Helpers.fileIcon(file.name), style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            Helpers.fileExtension(file.name),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onRemoveFile != null)
                      GestureDetector(
                        onTap: () => onRemoveFile!(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, color: AppColors.danger, size: 20),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'docx', 'xlsx', 'pptx', 'doc', 'xls', 'ppt'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files
            .where((f) => f.path != null)
            .map((f) => PickedFile(
              path: f.path!,
              name: f.name,
              size: f.size,
            ))
            .take(maxFiles - files.length)
            .toList();

        final allFiles = [...files, ...newFiles];
        onFilesPicked(allFiles);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }
}
