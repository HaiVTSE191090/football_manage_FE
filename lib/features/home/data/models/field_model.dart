class FieldModel {
  final String id;
  final String name;
  final String address;
  final String district;
  final double rating;
  final int reviewCount;
  final int pricePerHour;
  final String imageUrl;
  final double distanceKm;
  final List<String> fieldTypes;
  final List<String> amenities;
  final String openingHours;
  final bool isFavorite;

  const FieldModel({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.rating,
    required this.reviewCount,
    required this.pricePerHour,
    required this.imageUrl,
    required this.distanceKm,
    required this.fieldTypes,
    required this.amenities,
    required this.openingHours,
    this.isFavorite = false,
  });

  FieldModel copyWith({bool? isFavorite}) {
    return FieldModel(
      id: id,
      name: name,
      address: address,
      district: district,
      rating: rating,
      reviewCount: reviewCount,
      pricePerHour: pricePerHour,
      imageUrl: imageUrl,
      distanceKm: distanceKm,
      fieldTypes: fieldTypes,
      amenities: amenities,
      openingHours: openingHours,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static List<FieldModel> get mockFields => const [
    FieldModel(
      id: 'f1',
      name: 'Sân bóng Chảo Lửa Tân Bình',
      address: '30 Phan Thúc Duyện, Phường 4',
      district: 'Tân Bình',
      rating: 4.9,
      reviewCount: 184,
      pricePerHour: 280000,
      imageUrl:
          'https://images.unsplash.com/photo-1529900241929-5ed53caa4305?w=800&q=80',
      distanceKm: 1.2,
      fieldTypes: ['Sân 5', 'Sân 7'],
      amenities: ['Đèn LED chuẩn thi đấu', 'Cỏ nhân tạo FIFA', 'Bãi đỗ ô tô', 'Căng tin'],
      openingHours: '06:00 - 23:00',
    ),
    FieldModel(
      id: 'f2',
      name: 'Cụm Sân bóng K34 Bạch Đằng',
      address: 'K34 Bạch Đằng, Phường 2',
      district: 'Tân Bình',
      rating: 4.8,
      reviewCount: 96,
      pricePerHour: 250000,
      imageUrl:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
      distanceKm: 2.5,
      fieldTypes: ['Sân 5', 'Sân 7', 'Sân 11'],
      amenities: ['Khán đài có mái che', 'Phòng thay đồ nóng lạnh', 'Cho thuê giày & áo'],
      openingHours: '06:00 - 24:00',
    ),
    FieldModel(
      id: 'f3',
      name: 'Sân bóng Đại học Bách Khoa',
      address: '268 Lý Thường Kiệt, Phường 14',
      district: 'Quận 10',
      rating: 4.7,
      reviewCount: 230,
      pricePerHour: 220000,
      imageUrl:
          'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800&q=80',
      distanceKm: 3.8,
      fieldTypes: ['Sân 5', 'Sân 7'],
      amenities: ['Cỏ mới bảo dưỡng', 'Nước uống miễn phí', 'Wifi tốc độ cao'],
      openingHours: '06:00 - 22:30',
    ),
    FieldModel(
      id: 'f4',
      name: 'Trung tâm Thể thao Celadon Sport Club',
      address: 'Số 2 Đường D2, Celadon City, Sơn Kỳ',
      district: 'Tân Phú',
      rating: 4.9,
      reviewCount: 310,
      pricePerHour: 350000,
      imageUrl:
          'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80',
      distanceKm: 4.6,
      fieldTypes: ['Sân 7', 'Sân 11'],
      amenities: ['Sân cỏ tự nhiên & nhân tạo', 'Phòng tắm VIP', 'Trọng tài chuyên nghiệp'],
      openingHours: '05:30 - 23:30',
    ),
  ];
}
