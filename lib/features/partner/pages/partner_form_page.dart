import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../data/partner_model.dart';
import '../form/partner_form_controller.dart';
import '../provider/partner_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/form/text_field_control.dart';
import '../../../shared/widgets/form/dropdown_control.dart';

class PartnerFormPage extends ConsumerStatefulWidget {
  final Partner? partner;
  const PartnerFormPage({super.key, this.partner});

  @override
  ConsumerState<PartnerFormPage> createState() => _PartnerFormPageState();
}

class _PartnerFormPageState extends ConsumerState<PartnerFormPage> {
  late final PartnerFormController _form;
  bool get _isEditing => widget.partner != null;

  @override
  void initState() {
    super.initState();
    _form = PartnerFormController();
    if (_isEditing) _form.prefill(widget.partner!);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _form.photoImage = file);
  }

  void _submit() async {
    if (!_form.validate()) return;

    final formData = FormData.fromMap({
      'name': _form.nameController.text.trim(),
      'email': _form.emailController.text.trim(),
      'address': _form.addressController.text.trim(),
      'mobile': _form.mobileController.text.trim(),
      'phone': _form.phoneController.text.trim(),
      'gender': _form.selectedGender,
      'partner_type': _form.selectedPartnerType,
      if (_form.photoImage != null)
        'photo_image': await MultipartFile.fromFile(
          _form.photoImage!.path,
          filename: _form.photoImage!.name,
        ),
    });

    try {
      if (_isEditing) {
        await ref
            .read(partnerProvider.notifier)
            .update(widget.partner!.id, formData);
      } else {
        await ref.read(partnerProvider.notifier).create(formData);
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
    final state = ref.watch(partnerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Partner' : 'New Partner')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: _form.photoImage != null
                          ? FileImage(File(_form.photoImage!.path))
                          : (widget.partner?.photoImage != null
                          ? NetworkImage(
                          widget.partner!.photoImage!)
                          : null)
                      as ImageProvider?,
                      child: _form.photoImage == null &&
                          widget.partner?.photoImage == null
                          ? const Icon(Icons.camera_alt, size: 32)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFieldControl(
                  label: 'Name',
                  controller: _form.nameController,
                  autoFocus: true,
                  validator: _form.validateName,
                ),
                TextFieldControl(
                  label: 'Email',
                  controller: _form.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _form.validateEmail,
                ),
                TextFieldControl(
                    label: 'Address',
                    controller: _form.addressController),
                TextFieldControl(
                  label: 'Mobile',
                  controller: _form.mobileController,
                  keyboardType: TextInputType.phone,
                ),
                TextFieldControl(
                  label: 'Phone',
                  controller: _form.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                StatefulBuilder(
                  builder: (context, setLocal) => DropdownControl<String>(
                    label: 'Gender',
                    value: _form.selectedGender,
                    items: _form.genders
                        .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                            g[0].toUpperCase() + g.substring(1))))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => _form.selectedGender = v!),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setLocal) => DropdownControl<String>(
                    label: 'Partner Type',
                    value: _form.selectedPartnerType,
                    items: _form.partnerTypes
                        .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                            t[0].toUpperCase() + t.substring(1))))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => _form.selectedPartnerType = v!),
                  ),
                ),
                const SizedBox(height: 8),
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