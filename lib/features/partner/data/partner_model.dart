class Partner {
  final int id;
  final String name;
  final String email;
  final String? address;
  final String? mobile;
  final String? phone;
  final String? gender;
  final String? partnerType;
  final String? photoImage;

  Partner({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.mobile,
    this.phone,
    this.gender,
    this.partnerType,
    this.photoImage,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
    id: int.parse(json['id'].toString()),
    name: json['name'],
    email: json['email'],
    address: json['address'],
    mobile: json['mobile'],
    phone: json['phone'],
    gender: json['gender'],
    partnerType: json['partner_type'],
    photoImage: json['photo_image'],
  );
}