import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samiti_mobile_app/features/accident/data/accident_model.dart';
class AccidentImageUpload extends StatefulWidget {
  final List<AccidentImage> existingImages;
  final List<XFile> newImages;
  final void Function(List<XFile> newImages, List<int> deletedIds)
  onChanged;

  const AccidentImageUpload({
    super.key,
    required this.existingImages,
    required this.newImages,
    required this.onChanged,
  });

  @override
  State<AccidentImageUpload> createState() => _AccidentImageUploadState();
}

class _AccidentImageUploadState extends State<AccidentImageUpload> {
  late List<AccidentImage> _existingImages;
  late List<XFile> _newImages;
  final List<int> _deletedIds = [];

  @override
  void initState() {
    super.initState();
    _existingImages = List.from(widget.existingImages);
    _newImages = List.from(widget.newImages);
  }

  Future<void> _pickImage() async {
    final file =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _newImages.add(file));
      _notify();
    }
  }

  void _removeExisting(AccidentImage image) {
    setState(() {
      _existingImages.remove(image);
      _deletedIds.add(image.id); // track for delete command
    });
    _notify();
  }

  void _removeNew(int index) {
    setState(() => _newImages.removeAt(index));
    _notify();
  }

  void _notify() =>
      widget.onChanged(_newImages, List.from(_deletedIds));

  void _viewImage(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(child: Image(image: image)),
      ),
    );
  }

  Widget _buildTile({
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
              image:
              DecorationImage(image: image, fit: BoxFit.cover),
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
                  color: Colors.red, shape: BoxShape.circle),
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
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // existing images from server
            ..._existingImages.map((img) {
              final image = NetworkImage(img.image);
              return _buildTile(
                image: image,
                onView: () => _viewImage(context, image),
                onRemove: () => _removeExisting(img),
              );
            }),

            // newly picked images
            ..._newImages.asMap().entries.map((entry) {
              final image = FileImage(File(entry.value.path));
              return _buildTile(
                image: image,
                onView: () => _viewImage(context, image),
                onRemove: () => _removeNew(entry.key),
              );
            }),

            // add button
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