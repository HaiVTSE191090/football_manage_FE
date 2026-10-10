class MatchTeamModel {
  final String id;
  final String teamName;
  final String captain;
  final String phone;
  final String date;
  final String time;
  final String fieldName;
  final String fieldSize;
  final String level;
  final String feeRule;
  final String avatarUrl;
  final bool isJoined;

  const MatchTeamModel({
    required this.id,
    required this.teamName,
    required this.captain,
    required this.phone,
    required this.date,
    required this.time,
    required this.fieldName,
    required this.fieldSize,
    required this.level,
    required this.feeRule,
    required this.avatarUrl,
    this.isJoined = false,
  });

  MatchTeamModel copyWith({bool? isJoined}) {
    return MatchTeamModel(
      id: id,
      teamName: teamName,
      captain: captain,
      phone: phone,
      date: date,
      time: time,
      fieldName: fieldName,
      fieldSize: fieldSize,
      level: level,
      feeRule: feeRule,
      avatarUrl: avatarUrl,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  static List<MatchTeamModel> get mockMatches => const [
    MatchTeamModel(
      id: 'm1',
      teamName: 'FC Phủi Sài Gòn',
      captain: 'Vũ THanh Hải',
      phone: '0326009047',
      date: 'Hôm nay',
      time: '19:30 - 21:00',
      fieldName: 'Sân bóng Chảo Lửa Tân Bình',
      fieldSize: 'Sân 7',
      level: 'Trung bình - Khá',
      feeRule: 'Kèo 5-5 (Chia đôi tiền sân)',
      avatarUrl:
          'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
    ),
    MatchTeamModel(
      id: 'm2',
      teamName: 'Bách Khoa Legends',
      captain: 'Lâm Hoàng Hải Đăng',
      phone: '0987654321',
      date: 'Tối mai',
      time: '20:00 - 21:30',
      fieldName: 'Sân ĐH Bách Khoa',
      fieldSize: 'Sân 5',
      level: 'Giao lưu vui vẻ, văn minh',
      feeRule: 'Thua trả tiền nước',
      avatarUrl:
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=400&q=80',
    ),
    MatchTeamModel(
      id: 'm3',
      teamName: 'Lâu Đài FC',
      captain: 'Đàm Vĩnh Hưng',
      phone: '0903112233',
      date: 'Thứ Bảy',
      time: '17:30 - 19:00',
      fieldName: 'Cụm Sân K34 Bạch Đằng',
      fieldSize: 'Sân 7',
      level: 'Khá - Cứng',
      feeRule: 'Kèo 5-5',
      avatarUrl:
          'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=400&q=80',
    ),
  ];
}
