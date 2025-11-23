import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import 'translated_widget.dart';

enum UploadSourceType { camera, gallery, file }

class UploadSelector {
  static Future<String?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<UploadSourceType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheet(context),
    );

    if (source == null) return null;

    if (source == UploadSourceType.camera) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      return image?.path;
    } else if (source == UploadSourceType.gallery) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image?.path;
    } else if (source == UploadSourceType.file) {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      return result?.files.single.path;
    }
    return null;
  }

  static Widget _buildBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AutoTranslateText(
            'Upload Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            context,
            icon: LucideIcons.camera,
            color: Colors.blue,
            text: 'Take Picture',
            source: UploadSourceType.camera,
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: LucideIcons.image,
            color: Colors.purple,
            text: 'Choose from Gallery',
            source: UploadSourceType.gallery,
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            icon: LucideIcons.fileText,
            color: Colors.orange,
            text: 'Upload Document',
            source: UploadSourceType.file,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    required UploadSourceType source,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: AutoTranslateText(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      onTap: () => Navigator.pop(context, source),
    );
  }
}
