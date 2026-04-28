import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/form/base_form_controller.dart';
import '../../../core/form/form_validator.dart';
import '../data/vehicle_model.dart';

class VehicleFormController extends BaseFormController {
  final vehicleNoController = TextEditingController();
  final modelNoController = TextEditingController();

  final List<String> fuelTypes = ['diesel', 'petrol', 'electric'];
  String selectedFuelType = 'diesel';

  int? selectedPartnerId;
  XFile? vehicleImage;
  XFile? billbookImage;

  String? validateVehicleNo(String? v) =>
      FormValidator.required(v, label: 'Vehicle No');

  void prefill(Vehicle vehicle) {
    vehicleNoController.text = vehicle.vehicleNo;
    modelNoController.text = vehicle.modelNo ?? '';
    selectedFuelType = vehicle.fuelType ?? 'diesel';
    selectedPartnerId = vehicle.partner?.id;
  }

  @override
  void dispose() {
    vehicleNoController.dispose();
    modelNoController.dispose();
  }
}