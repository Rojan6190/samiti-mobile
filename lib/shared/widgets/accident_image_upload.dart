import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccidentImageUpload extends StatefulWidget {
  final List<String> existingImageUrls;
  final List<XFile> newImages;
  final void Function(List<XFile>) onImagesChanged;

  const AccidentImageUpload({
    super.key,
    required this.existingImageUrls,
    required this.newImages,
    required this.onImagesChanged,
  });

  @override
  State<AccidentImageUpload> createState() => _AccidentImageUploadState();
}

class _AccidentImageUploadState extends State<AccidentImageUpload> {
  late List<XFile> _newImages;

  @override
  void initState() {
    super.initState();
    _newImages = List.from(widget.newImages);
  }

  Future<void> _pickImage() async {
    final file =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _newImages.add(file));
      widget.onImagesChanged(_newImages);
    }
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
    widget.onImagesChanged(_newImages);
  }

  void _viewImage(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image(image: image)),
      ),
    );
  }

  Widget _buildImageTile({
    required ImageProvider image,
    required VoidCallback onRemove,
    required VoidCallback onView,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onView,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close,
                  size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Images',
            style:
            TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...widget.existingImageUrls.map((url) {
              final image = NetworkImage(url);
              return _buildImageTile(
                image: image,
                onView: () => _viewImage(context, image),
                onRemove: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'To delete existing images contact admin')),
                  );
                },
              );
            }),
            ..._newImages.asMap().entries.map((entry) {
              final image = FileImage(File(entry.value.path));
              return _buildImageTile(
                image: image,
                onView: () => _viewImage(context, image),
                onRemove: () => _removeNewImage(entry.key),
              );
            }),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.grey),
                    SizedBox(height: 4),
                    Text('Add Image',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}