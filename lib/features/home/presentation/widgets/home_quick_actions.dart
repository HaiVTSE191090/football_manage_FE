import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onBookFieldTap;
  final VoidCallback onFacilityMapTap;
  final VoidCallback onRefereeEquipmentTap;
  final VoidCallback onSportsStoreTap;
  final VoidCallback onTournamentsTap;
  final VoidCallback onAIChatTap;
  final VoidCallback onFindMatchTap;
  final VoidCallback onSplitBillTap;

  const HomeQuickActions({
    super.key,
    required this.onBookFieldTap,
    required this.onFacilityMapTap,
    required this.onRefereeEquipmentTap,
    required this.onSportsStoreTap,
    required this.onTournamentsTap,
    required this.onAIChatTap,
    required this.onFindMatchTap,
    required this.onSplitBillTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickActionItem(
        label: 'Đặt sân nhanh',
        icon: Iconsax.calendar_tick,
        color: const Color(0xFF16A34A),
        onTap: onBookFieldTap,
      ),
      QuickActionItem(
        label: 'Bản đồ cơ sở',
        icon: Iconsax.map_1,
        color: const Color(0xFF7C3AED),
        onTap: onFacilityMapTap,
      ),
      QuickActionItem(
        label: 'Trọng tài & Đồ',
        icon: Iconsax.judge,
        color: const Color(0xFF0D9488),
        onTap: onRefereeEquipmentTap,
      ),
      QuickActionItem(
        label: 'Cửa hàng tiện ích',
        icon: Iconsax.shop,
        color: const Color(0xFF0284C7),
        onTap: onSportsStoreTap,
      ),
      QuickActionItem(
        label: 'Giải đấu & Đội',
        icon: Iconsax.cup,
        color: const Color(0xFFEA580C),
        onTap: onTournamentsTap,
      ),
      QuickActionItem(
        label: 'AI Trợ lý sân',
        icon: Icons.smart_toy_rounded,
        color: const Color(0xFF059669),
        onTap: onAIChatTap,
      ),
      QuickActionItem(
        label: 'Tìm đối giao lưu',
        icon: Iconsax.profile_2user,
        color: const Color(0xFF2563EB),
        onTap: onFindMatchTap,
      ),
      QuickActionItem(
        label: 'Chia tiền sân',
        icon: Iconsax.card,
        color: const Color(0xFFCA8A04),
        onTap: onSplitBillTap,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dịch vụ & Tính năng hệ thống',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              return InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
