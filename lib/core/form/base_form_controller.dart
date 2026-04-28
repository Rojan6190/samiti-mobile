import 'package:flutter/material.dart';

abstract class BaseFormController {

  final formKey = GlobalKey<FormState>();

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose();

}
