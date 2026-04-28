import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/product_model.dart';
import '../provider/product_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/form/text_field_control.dart';
import '../../../shared/widgets/form/dropdown_control.dart';
import '../../../shared/widgets/form/number_field_control.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'service';
  final List<String> _types = ['service', 'product'];
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _codeController.text = widget.product!.code ?? '';
      _priceController.text = widget.product!.listPrice.toString();
      _selectedType = widget.product!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'list_price': double.parse(_priceController.text),
      'type': _selectedType,
    };
    try {
      if (_isEditing) {
        await ref
            .read(productProvider.notifier)
            .update(widget.product!.id, data);
      } else {
        await ref.read(productProvider.notifier).create(data);
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
    final state = ref.watch(productProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
          title: Text(_isEditing ? 'Edit Product' : 'New Product')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldControl(
                  label: 'Name',
                  controller: _nameController,
                  autoFocus: true,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFieldControl(
                    label: 'Code', controller: _codeController),
                NumberFieldControl(
                  label: 'List Price',
                  controller: _priceController,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
                ),
                StatefulBuilder(
                  builder: (context, setLocal) => DropdownControl<String>(
                    label: 'Type',
                    value: _selectedType,
                    items: _types
                        .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => _selectedType = v!),
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