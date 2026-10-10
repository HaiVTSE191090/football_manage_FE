class TournamentModel {
  final String id;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final int maxTeams;
  final int registeredTeamsCount;
  final String status; // 'OPEN_REGISTRATION', 'ONGOING', 'COMPLETED'
  final String bannerUrl;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.maxTeams,
    required this.registeredTeamsCount,
    required this.status,
    required this.bannerUrl,
  });

  static List<TournamentModel> get mockTournaments => const [
    TournamentModel(
      id: 'tour_1',
      name: 'Cúp Phủi Mùa Hè ABC 2026',
      description: 'Giải đấu quy tụ 16 đội bóng phong trào hàng đầu tranh cúp vô địch và giải thưởng 20.000.000đ.',
      startDate: '15/10/2026',
      endDate: '30/10/2026',
      maxTeams: 16,
      registeredTeamsCount: 12,
      status: 'OPEN_REGISTRATION',
      bannerUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80',
    ),
    TournamentModel(
      id: 'tour_2',
      name: 'Giải Tứ Hùng Doanh Nghiệp Mở Rộng',
      description: 'Giải đấu giao lưu gắn kết thể thao giữa các doanh nghiệp tại cụm sân Quận 7.',
      startDate: '01/11/2026',
      endDate: '05/11/2026',
      maxTeams: 8,
      registeredTeamsCount: 8,
      status: 'ONGOING',
      bannerUrl: 'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=800&q=80',
    ),
  ];
}

class TournamentMatchModel {
  final String id;
  final String tournamentId;
  final String teamA;
  final String teamB;
  final String fieldName;
  final String refereeName;
  final String matchTime;
  final int? scoreA;
  final int? scoreB;
  final String status; // 'UPCOMING', 'LIVE', 'COMPLETED'

  const TournamentMatchModel({
    required this.id,
    required this.tournamentId,
    required this.teamA,
    required this.teamB,
    required this.fieldName,
    required this.refereeName,
    required this.matchTime,
    this.scoreA,
    this.scoreB,
    required this.status,
  });

  static List<TournamentMatchModel> get mockMatches => const [
    TournamentMatchModel(
      id: 'tm_1',
      tournamentId: 'tour_1',
      teamA: 'FC Phủi Sài Gòn',
      teamB: 'Bách Khoa Legends',
      fieldName: 'Sân 7A - Cơ sở Quận 7',
      refereeName: 'Nguyễn Văn An (Standard)',
      matchTime: '18:00 - 15/10/2026',
      status: 'UPCOMING',
    ),
    TournamentMatchModel(
      id: 'tm_2',
      tournamentId: 'tour_1',
      teamA: 'Lâu Đài FC',
      teamB: 'Gia Định Warriors',
      fieldName: 'Sân 7B - Cơ sở Quận 7',
      refereeName: 'Trần Minh Quân (Pro)',
      matchTime: '19:30 - 15/10/2026',
      status: 'UPCOMING',
    ),
    TournamentMatchModel(
      id: 'tm_3',
      tournamentId: 'tour_2',
      teamA: 'TechCorp FC',
      teamB: 'Bankers United',
      fieldName: 'Sân 5A - Cơ sở Bình Thạnh',
      refereeName: 'Lê Hoàng Nam (Basic)',
      matchTime: '20:00 - Hôm qua',
      scoreA: 3,
      scoreB: 2,
      status: 'COMPLETED',
    ),
  ];
}

class TournamentStandingModel {
  final int rank;
  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;

  const TournamentStandingModel({
    required this.rank,
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalDifference,
    required this.points,
  });

  static List<TournamentStandingModel> get mockStandings => const [
    TournamentStandingModel(
      rank: 1,
      teamName: 'TechCorp FC',
      played: 3,
      won: 3,
      drawn: 0,
      lost: 0,
      goalDifference: 7,
      points: 9,
    ),
    TournamentStandingModel(
      rank: 2,
      teamName: 'Bankers United',
      played: 3,
      won: 2,
      drawn: 0,
      lost: 1,
      goalDifference: 3,
      points: 6,
    ),
    TournamentStandingModel(
      rank: 3,
      teamName: 'Logistics Stars',
      played: 3,
      won: 1,
      drawn: 0,
      lost: 2,
      goalDifference: -2,
      points: 3,
    ),
    TournamentStandingModel(
      rank: 4,
      teamName: 'Media Agency FC',
      played: 3,
      won: 0,
      drawn: 0,
      lost: 3,
      goalDifference: -8,
      points: 0,
    ),
  ];
}
