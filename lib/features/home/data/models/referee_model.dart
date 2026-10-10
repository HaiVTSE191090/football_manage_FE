class RefereeModel {
  final String id;
  final String name;
  final String phone;
  final String level; // 'BASIC', 'STANDARD', 'PROFESSIONAL'
  final int hourlyRate;
  final String status; // 'AVAILABLE', 'BUSY'
  final String avatarUrl;
  final double rating;
  final int matchesOfficiated;

  const RefereeModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.level,
    required this.hourlyRate,
    this.status = 'AVAILABLE',
    required this.avatarUrl,
    required this.rating,
    required this.matchesOfficiated,
  });

  String get levelLabel {
    switch (level) {
      case 'BASIC':
        return 'Cơ bản (Basic)';
      case 'STANDARD':
        return 'Tiêu chuẩn (Standard)';
      case 'PROFESSIONAL':
        return 'Chuyên nghiệp (Pro)';
      default:
        return level;
    }
  }

  static List<RefereeModel> get mockReferees => const [
    RefereeModel(
      id: 'ref_1',
      name: 'Nguyễn Văn An',
      phone: '0912 345 678',
      level: 'STANDARD',
      hourlyRate: 150000,
      status: 'AVAILABLE',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      rating: 4.8,
      matchesOfficiated: 142,
    ),
    RefereeModel(
      id: 'ref_2',
      name: 'Trần Minh Quân',
      phone: '0988 776 655',
      level: 'PROFESSIONAL',
      hourlyRate: 220000,
      status: 'AVAILABLE',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80',
      rating: 4.9,
      matchesOfficiated: 310,
    ),
    RefereeModel(
      id: 'ref_3',
      name: 'Lê Hoàng Nam',
      phone: '0933 221 100',
      level: 'BASIC',
      hourlyRate: 100000,
      status: 'AVAILABLE',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&q=80',
      rating: 4.6,
      matchesOfficiated: 65,
    ),
  ];
}
