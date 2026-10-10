class FacilityModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String description;
  final String openingTime;
  final String closingTime;
  final String status; // 'ACTIVE', 'INACTIVE'
  final double distanceKm;
  final int fieldCount;
  final String imageUrl;

  const FacilityModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.description,
    required this.openingTime,
    required this.closingTime,
    this.status = 'ACTIVE',
    required this.distanceKm,
    required this.fieldCount,
    required this.imageUrl,
  });

  static List<FacilityModel> get mockFacilities => const [
    FacilityModel(
      id: 'fac_q7',
      name: 'Football Center ABC - Cơ sở Quận 7',
      address: 'Số 102 Đường Nguyễn Thị Thập, Tân Hưng, Quận 7, TP.HCM',
      latitude: 10.7382,
      longitude: 106.7091,
      phone: '0909 123 456',
      description: 'Hệ thống cụm sân 5, 7 và 11 người mặt cỏ chuẩn FIFA với hệ thống đèn cao áp hiện đại.',
      openingTime: '06:00',
      closingTime: '23:30',
      status: 'ACTIVE',
      distanceKm: 2.4,
      fieldCount: 8,
      imageUrl: 'https://images.unsplash.com/photo-1529900241929-5ed53caa4305?w=800&q=80',
    ),
    FacilityModel(
      id: 'fac_thuduc',
      name: 'Football Center ABC - Cơ sở Thủ Đức',
      address: 'Đường Kha Vạn Cân, Linh Trung, TP. Thủ Đức, TP.HCM',
      latitude: 10.8524,
      longitude: 106.7712,
      phone: '0909 654 321',
      description: 'Khu liên hợp sân cỏ tự nhiên và nhân tạo, có khán đài có mái che và bãi đỗ xe lớn.',
      openingTime: '06:00',
      closingTime: '23:00',
      status: 'ACTIVE',
      distanceKm: 5.8,
      fieldCount: 6,
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
    ),
    FacilityModel(
      id: 'fac_binhthanh',
      name: 'Football Center ABC - Cơ sở Bình Thạnh',
      address: '152 Chu Văn An, Phường 26, Bình Thạnh, TP.HCM',
      latitude: 10.8142,
      longitude: 106.7088,
      phone: '0909 888 999',
      description: 'Cơ sở trung tâm trang bị phòng thay đồ máy lạnh, nước uống giải khát và dịch vụ trọng tài chuyên nghiệp.',
      openingTime: '06:00',
      closingTime: '24:00',
      status: 'ACTIVE',
      distanceKm: 3.6,
      fieldCount: 5,
      imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800&q=80',
    ),
  ];
}
