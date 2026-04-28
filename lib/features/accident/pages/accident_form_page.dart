import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/accident_model.dart';
import '../form/accident_form_controller.dart';
import '../provider/accident_provider.dart';
import '../../../shared/widgets/accident_image_upload.dart';
import '../../vehicle/provider/vehicle_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/form/text_field_control.dart';
import '../../../shared/widgets/form/dropdown_control.dart';

class AccidentFormPage extends ConsumerStatefulWidget {
  final Accident? accident;
  const AccidentFormPage({super.key, this.accident});

  @override
  ConsumerState<AccidentFormPage> createState() => _AccidentFormPageState();
}

class _AccidentFormPageState extends ConsumerState<AccidentFormPage> {
  late final AccidentFormController _form;
  bool get _isEditing => widget.accident != null;

  @override
  void initState() {
    super.initState();
    _form = AccidentFormController();
    if (_isEditing) _form.prefill(widget.accident!);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_form.validate()) return;
    if (_form.selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    final imageFiles = await Future.wait(
      _form.newImages.asMap().entries.map((entry) async {
        return MapEntry(
          'images[${entry.key}][image]',
          await MultipartFile.fromFile(
            entry.value.path,
            filename: entry.value.name,
          ),
        );
      }),
    );

    final formData = FormData.fromMap({
      'name': _form.nameController.text.trim(),
      'vehicle': _form.selectedVehicleId.toString(),
      'driver_name': _form.driverNameController.text.trim(),
      'accident_place': _form.accidentPlaceController.text.trim(),
      'accident_cause': _form.accidentCauseController.text.trim(),
      'remarks': _form.remarksController.text.trim(),
      ...Map.fromEntries(imageFiles),
    });

    try {
      if (_isEditing) {
        await ref
            .read(accidentProvider.notifier)
            .update(widget.accident!.id, formData);
      } else {
        await ref.read(accidentProvider.notifier).create(formData);
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
    final state = ref.watch(accidentProvider);
    final vehiclesState = ref.watch(vehicleProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Accident' : 'New Accident')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldControl(
                  label: 'Name',
                  controller: _form.nameController,
                  autoFocus: true,
                  validator: _form.validateName,
                ),
                vehiclesState.when(
                  loading: () =>
                  const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Text('Error loading vehicles: $e'),
                  data: (vehicles) => StatefulBuilder(
                    builder: (context, setLocal) =>
                        DropdownControl<int>(
                          label: 'Vehicle',
                          value: _form.selectedVehicleId ??
                              vehicles.first.id,
                          items: vehicles
                              .map((v) => DropdownMenuItem(
                              value: v.id,
                              child: Text(v.vehicleNo)))
                              .toList(),
                          onChanged: (v) => setLocal(
                                  () => _form.selectedVehicleId = v),
                        ),
                  ),
                ),
                TextFieldControl(
                    label: 'Driver Name',
                    controller: _form.driverNameController),
                TextFieldControl(
                    label: 'Accident Place',
                    controller: _form.accidentPlaceController),
                TextFieldControl(
                    label: 'Accident Cause',
                    controller: _form.accidentCauseController),
                TextFieldControl(
                    label: 'Remarks',
                    controller: _form.remarksController),
                const SizedBox(height: 16),
                AccidentImageUpload(
                  existingImageUrls: widget.accident?.images
                      .map((e) => e.image)
                      .toList() ??
                      [],
                  newImages: _form.newImages,
                  onImagesChanged: (images) =>
                      setState(() => _form.newImages = images),
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