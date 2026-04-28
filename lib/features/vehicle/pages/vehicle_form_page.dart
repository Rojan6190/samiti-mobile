import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../data/vehicle_model.dart';
import '../form/vehicle_form_controller.dart';
import '../provider/vehicle_provider.dart';
import '../../partner/data/partner_model.dart';
import '../../partner/provider/partner_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/form/text_field_control.dart';
import '../../../shared/widgets/form/dropdown_control.dart';

class VehicleFormPage extends ConsumerStatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormPage({super.key, this.vehicle});

  @override
  ConsumerState<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends ConsumerState<VehicleFormPage> {
  late final VehicleFormController _form;
  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _form = VehicleFormController();
    if (_isEditing) _form.prefill(widget.vehicle!);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isVehicle) async {
    final file =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (isVehicle) {
          _form.vehicleImage = file;
        } else {
          _form.billbookImage = file;
        }
      });
    }
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? file,
    required String? existingUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: file != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(file.path), fit: BoxFit.cover),
        )
            : existingUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
          Image.network(existingUrl, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt,
                size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_form.validate()) return;
    if (_form.selectedPartnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a partner')),
      );
      return;
    }

    final formData = FormData.fromMap({
      'vehicle_no': _form.vehicleNoController.text.trim(),
      'partner': _form.selectedPartnerId.toString(),
      'fuel_type': _form.selectedFuelType,
      'model_no': _form.modelNoController.text.trim(),
      if (_form.vehicleImage != null)
        'vehicle_image': await MultipartFile.fromFile(
          _form.vehicleImage!.path,
          filename: _form.vehicleImage!.name,
        ),
      if (_form.billbookImage != null)
        'billbook_image': await MultipartFile.fromFile(
          _form.billbookImage!.path,
          filename: _form.billbookImage!.name,
        ),
    });

    try {
      if (_isEditing) {
        await ref
            .read(vehicleProvider.notifier)
            .update(widget.vehicle!.id, formData);
      } else {
        await ref.read(vehicleProvider.notifier).create(formData);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleProvider);
    final partnersState = ref.watch(partnerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Vehicle' : 'New Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldControl(
                  label: 'Vehicle No',
                  controller: _form.vehicleNoController,
                  autoFocus: true,
                  validator: _form.validateVehicleNo,
                ),
                TextFieldControl(
                    label: 'Model No',
                    controller: _form.modelNoController),
                partnersState.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Text('Error loading partners: $e'),
                  data: (partners) => StatefulBuilder(
                    builder: (context, setLocal) =>
                        DropdownControl<int>(
                          label: 'Partner',
                          value: _form.selectedPartnerId ??
                              partners.first.id,
                          items: partners
                              .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (v) => setLocal(
                                  () => _form.selectedPartnerId = v),
                        ),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setLocal) => DropdownControl<String>(
                    label: 'Fuel Type',
                    value: _form.selectedFuelType,
                    items: _form.fuelTypes
                        .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                            f[0].toUpperCase() + f.substring(1))))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => _form.selectedFuelType = v!),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Vehicle Image',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildImagePicker(
                  label: 'Tap to upload vehicle image',
                  file: _form.vehicleImage,
                  existingUrl: widget.vehicle?.vehicleImage,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 16),
                const Text('Billbook Image',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildImagePicker(
                  label: 'Tap to upload billbook image',
                  file: _form.billbookImage,
                  existingUrl: widget.vehicle?.billbookImage,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 16),
                LoadingButton(
                  isLoading: isLoading,
                  onPressed: _submit,
                  label: _isEditing ? 'Update' : 'Create',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}