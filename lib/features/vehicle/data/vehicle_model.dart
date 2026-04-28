import 'package:samiti_mobile_app/features/partner/data/partner_model.dart';

class Vehicle {
  final int id;
  final String vehicleNo;
  final Partner? partner;
  final String? vehicleBrand;
  final String? vehicleType;
  final String? fuelType;
  final String? modelNo;
  final String? vehicleImage;
  final String? billbookImage;

  Vehicle({
    required this.id,
    required this.vehicleNo,
    this.partner,
    this.vehicleBrand,
    this.vehicleType,
    this.fuelType,
    this.modelNo,
    this.vehicleImage,
    this.billbookImage,
});
  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: int.parse(json['id'].toString()),
    vehicleNo: json['vehicle_no'],
    partner: json['partner'] != null
        ? Partner.fromJson(json['partner'])
        : null,
    vehicleBrand: json['vehicle_brand']?.toString(),
    vehicleType: json['vehicle_type']?.toString(),
    fuelType: json['fuel_type'],
    modelNo: json['model_no'],
    vehicleImage: json['vehicle_image'],
    billbookImage: json['billbook_image'],
  );


}