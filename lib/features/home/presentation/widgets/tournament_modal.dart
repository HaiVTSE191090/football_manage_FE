import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../data/models/tournament_model.dart';

class TournamentModal extends StatefulWidget {
  const TournamentModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TournamentModal(),
    );
  }

  @override
  State<TournamentModal> createState() => _TournamentModalState();
}

class _TournamentModalState extends State<TournamentModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TournamentModel> _tournaments = TournamentModel.mockTournaments;
  final List<TournamentMatchModel> _matches = TournamentMatchModel.mockMatches;
  final List<TournamentStandingModel> _standings = TournamentStandingModel.mockStandings;

  int _selectedTournamentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _registerTeamDialog(TournamentModel tour) {
    final teamCtrl = TextEditingController(text: 'FC Phủi Sài Gòn');
    final captainCtrl = TextEditingController(text: 'Vũ Thanh Hải');
    final phoneCtrl = TextEditingController(text: '0326 009 047');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Đăng Ký Tham Gia ${tour.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: teamCtrl, decoration: const InputDecoration(labelText: 'Tên đội bóng tham gia')),
            TextField(controller: captainCtrl, decoration: const InputDecoration(labelText: 'Đội trưởng')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Số điện thoại liên hệ')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng ký đội "${teamCtrl.text}" tham gia ${tour.name} thành công! Ban tổ chức sẽ liên hệ xếp lịch thi đấu.'),
                  backgroundColor: Colors.green.shade700,
                ),
              );
            },
            child: const Text('Xác nhận đăng ký'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tour = _tournaments[_selectedTournamentIndex];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 8),
            child: Row(
              children: [
                const Icon(Iconsax.cup, color: Color(0xFFEA580C)),
                const SizedBox(width: 10),
                const Text(
                  'Giải Đấu & Bảng Xếp Hạng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tournament selector chip row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_tournaments.length, (index) {
                final t = _tournaments[index];
                final isSelected = _selectedTournamentIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.name),
                    selected: isSelected,
                    selectedColor: const Color(0xFFEA580C),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedTournamentIndex = index),
                  ),
                );
              }),
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFEA580C),
            indicatorColor: const Color(0xFFEA580C),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Thông tin & Đăng ký'),
              Tab(text: 'Lịch thi đấu'),
              Tab(text: 'Bảng xếp hạng'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Info & Register
                _buildInfoTab(tour),
                // Tab 2: Match schedules (FR32, FR33)
                _buildMatchesTab(),
                // Tab 3: Standings (FR33)
                _buildStandingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(TournamentModel tour) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              tour.bannerUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 140,
                color: Colors.orange.shade100,
                child: const Icon(Iconsax.cup, size: 48, color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tour.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tour.status == 'OPEN_REGISTRATION' ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tour.status == 'OPEN_REGISTRATION' ? 'Đang mở đăng ký' : 'Đang diễn ra',
                  style: TextStyle(
                    color: tour.status == 'OPEN_REGISTRATION' ? Colors.green.shade700 : Colors.orange.shade800,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tour.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildDetailRow('Thời gian tổ chức:', '${tour.startDate} - ${tour.endDate}'),
                const SizedBox(height: 6),
                _buildDetailRow('Quy mô:', '${tour.maxTeams} đội bóng tham gia'),
                const SizedBox(height: 6),
                _buildDetailRow('Đã đăng ký:', '${tour.registeredTeamsCount} / ${tour.maxTeams} đội'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _registerTeamDialog(tour),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Đăng ký đội bóng tham gia giải', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final m = _matches[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('🕒 ${m.matchTime}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: m.status == 'COMPLETED' ? Colors.grey.shade100 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      m.status == 'COMPLETED' ? 'Đã kết thúc' : 'Sắp diễn ra',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: m.status == 'COMPLETED' ? Colors.grey.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.teamA,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.status == 'COMPLETED' ? '${m.scoreA} - ${m.scoreB}' : 'VS',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFEA580C)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      m.teamB,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📍 ${m.fieldName} • Trọng tài: ${m.refereeName}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(4.5),
          2: FlexColumnWidth(1.2),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            children: const [
              Padding(padding: EdgeInsets.all(8), child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Đội bóng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Trận', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('H', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Điểm', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFEA580C)))),
            ],
          ),
          ..._standings.map((s) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Text('${s.rank}', style: TextStyle(fontWeight: FontWeight.bold, color: s.rank <= 2 ? Colors.orange.shade800 : Colors.black87)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Text(s.teamName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('${s.played}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('${s.won}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('${s.drawn}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('${s.points}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEA580C))),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
