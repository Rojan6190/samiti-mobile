import 'package:samiti_mobile_app/features/vehicle/data/vehicle_model.dart';

class AccidentImage{
  final int id;
  final String image;

  AccidentImage({required this.id, required this.image});

  factory AccidentImage.fromJson(Map<String, dynamic> json) => AccidentImage(
      id: int.parse(json['id'].toString()),
      image: json['image']
  );
}

class Accident{
  final int id;
  final String name;
  final Vehicle? vehicle;
  final String? accidentDate;
  final String? driverName;
  final String? accidentPlace;
  final String? accidentCause;
  final String? remarks;
  final List<AccidentImage> images;

  Accident({
    required this.id,
    required this.name,
    this.vehicle,
    this.accidentDate,
    this.driverName,
    this.accidentPlace,
    this.accidentCause,
    this.remarks,
    this.images = const [],
});

  factory Accident.fromJson(Map<String, dynamic> json) => Accident(
    id: int.parse(json['id'].toString()),
    name: json['name'],
    vehicle: json['vehicle'] != null
        ? Vehicle.fromJson(json['vehicle'])
        : null,
    accidentDate: json['accident_date'],
    driverName: json['driver_name'],
    accidentPlace: json['accident_place'],
    accidentCause: json['accident_cause'],
    remarks: json['remarks'],
    images: (json['images'] as List? ?? [])
        .map((e) => AccidentImage.fromJson(e))
        .toList(),
  );
}