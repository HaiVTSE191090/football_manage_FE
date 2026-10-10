class BookingItemModel {
  final String id;
  final String bookingCode;
  final String fieldName;
  final String subFieldName;
  final String date;
  final String time;
  final int totalAmount;
  final int depositAmount;
  final String status; // 'confirmed', 'pending', 'completed', 'cancelled'
  final String? refereeName;
  final List<String> equipmentList;
  final String paymentOption; // 'DEPOSIT', 'FULL_PAYMENT'

  const BookingItemModel({
    required this.id,
    required this.bookingCode,
    required this.fieldName,
    required this.subFieldName,
    required this.date,
    required this.time,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
    this.refereeName,
    this.equipmentList = const [],
    this.paymentOption = 'DEPOSIT',
  });

  static List<BookingItemModel> get mockBookings => const [
    BookingItemModel(
      id: 'b1',
      bookingCode: 'FB-98214',
      fieldName: 'Sân bóng Chảo Lửa Tân Bình',
      subFieldName: 'Sân 7A - Cỏ nhân tạo',
      date: 'Hôm nay, 20:00 - 21:30',
      time: '20:00 - 21:30',
      totalAmount: 600000,
      depositAmount: 180000,
      status: 'confirmed',
      refereeName: 'Nguyễn Văn An (Standard - 150k/h)',
      equipmentList: ['1x Bóng thi đấu FIFA', '2x Giày (Size 41, 42)'],
      paymentOption: 'DEPOSIT',
    ),
    BookingItemModel(
      id: 'b2',
      bookingCode: 'FB-97451',
      fieldName: 'Cụm Sân bóng K34',
      subFieldName: 'Sân 5B',
      date: 'Chủ Nhật, 17:00 - 18:30',
      time: '17:00 - 18:30',
      totalAmount: 375000,
      depositAmount: 112500,
      status: 'pending',
      refereeName: null,
      equipmentList: ['1x Bóng thi đấu FIFA'],
      paymentOption: 'DEPOSIT',
    ),
    BookingItemModel(
      id: 'b3',
      bookingCode: 'FB-89102',
      fieldName: 'Sân bóng ĐH Bách Khoa',
      subFieldName: 'Sân 7C',
      date: '28/09/2026',
      time: '18:00 - 19:30',
      totalAmount: 330000,
      depositAmount: 330000,
      status: 'completed',
      refereeName: null,
      equipmentList: [],
      paymentOption: 'FULL_PAYMENT',
    ),
  ];
}
