import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/form/base_form_controller.dart';
import '../../../core/form/form_validator.dart';
import '../data/accident_model.dart';

class AccidentFormController extends BaseFormController {
  final nameController = TextEditingController();
  final driverNameController = TextEditingController();
  final accidentPlaceController = TextEditingController();
  final accidentCauseController = TextEditingController();
  final remarksController = TextEditingController();
  final accidentDateController = TextEditingController();


  int? selectedVehicleId;
  List<XFile> newImages = [];
  List<int> deletedImageIds = []; // ← track deleted existing images

  String? validateName(String? v) =>
      FormValidator.required(v, label: 'Name');

  void prefill(Accident accident) {
    nameController.text = accident.name;
    driverNameController.text = accident.driverName ?? '';
    accidentPlaceController.text = accident.accidentPlace ?? '';
    accidentCauseController.text = accident.accidentCause ?? '';
    remarksController.text = accident.remarks ?? '';
    selectedVehicleId = accident.vehicle?.id;
    // prefill date - take only date part (strip time)
    accidentDateController.text =
        accident.accidentDate?.substring(0,10) ?? ''; //added
  }

  Map<String, dynamic> get formFields => {
    'name': nameController.text.trim(),
    'vehicle': selectedVehicleId.toString(),
    'driver_name': driverNameController.text.trim(),
    'accident_place': accidentPlaceController.text.trim(),
    'accident_cause': accidentCauseController.text.trim(),
    'remarks': remarksController.text.trim(),
    'accident_date': accidentDateController.text.trim(), //added
  };

  @override
  void dispose() {
    nameController.dispose();
    driverNameController.dispose();
    accidentPlaceController.dispose();
    accidentCauseController.dispose();
    remarksController.dispose();
    accidentDateController.dispose();
  }
}