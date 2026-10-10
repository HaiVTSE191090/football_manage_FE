import 'dart:async';
import 'package:flutter/material.dart';

class BannerItem {
  final String title;
  final String subtitle;
  final String tag;
  final List<Color> gradientColors;
  final IconData icon;

  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.gradientColors,
    required this.icon,
  });
}

class HomePromoBanner extends StatefulWidget {
  final void Function(int index)? onBannerTap;

  const HomePromoBanner({super.key, this.onBannerTap});

  @override
  State<HomePromoBanner> createState() => _HomePromoBannerState();
}

class _HomePromoBannerState extends State<HomePromoBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  static const List<BannerItem> _banners = [
    BannerItem(
      tag: 'ƯU ĐÃI GIỜ VÀNG',
      title: 'Giảm 25% Tiền Sân',
      subtitle: 'Khung giờ 14:00 - 17:00 các ngày trong tuần',
      gradientColors: [Color(0xFF15803D), Color(0xFF16A34A), Color(0xFF22C55E)],
      icon: Icons.flash_on_rounded,
    ),
    BannerItem(
      tag: 'GIẢI ĐẤU MÙA HÈ',
      title: 'Cúp Phủi Champion 2026',
      subtitle: 'Tổng giải thưởng 50.000.000 VNĐ. Đăng ký ngay!',
      gradientColors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
      icon: Icons.emoji_events_rounded,
    ),
    BannerItem(
      tag: 'TÌM ĐỐI GIAO LƯU',
      title: 'Ghép Đội Nhanh Chóng',
      subtitle: 'Hơn 500 đội bóng sẵn sàng thi đấu cuối tuần này',
      gradientColors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF475569)],
      icon: Icons.groups_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_banners.isEmpty) return;
      final nextPage = (_currentPage + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => widget.onBannerTap?.call(index),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: banner.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: banner.gradientColors.first.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative background shapes
                        Positioned(
                          right: -15,
                          bottom: -20,
                          child: Icon(
                            banner.icon,
                            size: 140,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner.tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Title
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Subtitle
                              Text(
                                banner.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.green.shade600
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
