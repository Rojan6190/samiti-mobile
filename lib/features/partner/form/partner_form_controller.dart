import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samiti_mobile_app/core/form/base_form_controller.dart';
import 'package:samiti_mobile_app/core/form/form_validator.dart';

class PartnerFormController extends BaseFormController{
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final phoneController = TextEditingController();

  final List<String> genders = ['male','female','other'];
  final List<String> partnerTypes = ['individual','company','joint'];

  String selectedGender = 'male';
  String selectedPartnerType = 'individual';
  XFile? photoImage;

  String? validateName(String ? v)=> FormValidator.required(v, label: 'Name');
  String? validateEmail(String? v)=> FormValidator.email(v);

  void prefill(partner) {
    nameController.text = partner.name;
    emailController.text = partner.email;
    addressController.text = partner.address??'';
    mobileController.text = partner.mobile??'';
    phoneController.text= partner.phone??'';
    selectedGender = partner.gender??'male';
    selectedPartnerType = partner.partnerType??'individual';

  }
  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    mobileController.dispose();
    phoneController.dispose();
    /*
Purpose: Prevents memory leaks by cleaning up controllers

When called: When the form screen is closed/destroyed

Why needed: TextEditingController listeners need explicit disposal

@override: Overrides BaseFormController.dispose()

Important: If you don't dispose controllers, you get:

Memory leaks

Performance degradation

Flutter warning in console
     */
  }



}