import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/models/booking_item_model.dart';
import '../../data/models/field_model.dart';
import '../../data/models/match_team_model.dart';
import '../widgets/ai_chat_modal.dart';
import '../widgets/booking_bottom_sheet.dart';
import '../widgets/facility_map_modal.dart';
import '../widgets/featured_fields_section.dart';
import '../widgets/home_header.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/match_finder_section.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/split_bill_dialog.dart';
import '../widgets/sports_store_modal.dart';
import '../widgets/tournament_modal.dart';
import '../widgets/upcoming_match_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0;
  String _currentLocation = 'Quận Tân Bình, TP.HCM';

  final TextEditingController _searchController = TextEditingController();
  List<FieldModel> _fields = List.from(FieldModel.mockFields);
  List<MatchTeamModel> _matches = List.from(MatchTeamModel.mockMatches);
  final List<BookingItemModel> _bookings = List.from(BookingItemModel.mockBookings);

  String _selectedFieldFilter = 'Tất cả';
  final List<String> _fieldFilterOptions = ['Tất cả', 'Sân 5', 'Sân 7', 'Sân 11'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _fields = List.from(FieldModel.mockFields);
      } else {
        _fields = FieldModel.mockFields.where((f) {
          final q = query.toLowerCase();
          return f.name.toLowerCase().contains(q) ||
              f.address.toLowerCase().contains(q) ||
              f.district.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _onFavoriteToggle(FieldModel field) {
    setState(() {
      final index = _fields.indexWhere((f) => f.id == field.id);
      if (index != -1) {
        _fields[index] = _fields[index].copyWith(isFavorite: !_fields[index].isFavorite);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          field.isFavorite
              ? 'Đã xóa khỏi danh sách yêu thích'
              : 'Đã thêm ${field.name} vào yêu thích!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openBookingSheet(FieldModel field) {
    BookingBottomSheet.show(
      context,
      field: field,
      onBookingSuccess: (newBooking) {
        setState(() {
          _bookings.insert(0, newBooking);
        });

        // Trigger payment flow for the booking deposit / full payment
        final amountToPay = newBooking.depositAmount > 0
            ? newBooking.depositAmount
            : newBooking.totalAmount;

        final numericBookingId = int.tryParse(newBooking.id.replaceAll(RegExp(r'[^0-9]'), ''));

        PaymentMethodSheet.show(
          context: context,
          title: 'Thanh Toán Đặt Sân (${newBooking.bookingCode})',
          amount: amountToPay,
          bookingId: numericBookingId,
          paymentType: newBooking.paymentOption == 'deposit' ? 'DEPOSIT' : 'FULL',
          onPaymentCompleted: (payment) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF16A34A),
                content: Text(
                  'Thanh toán đặt sân ${newBooking.bookingCode} thành công qua ${payment.paymentMethod}!',
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _onJoinMatch(MatchTeamModel match) {
    setState(() {
      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _matches[index] = _matches[index].copyWith(isJoined: !_matches[index].isJoined);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        content: Text(
          match.isJoined
              ? 'Đã hủy tham gia kèo'
              : 'Đã nhận kèo với ${match.teamName}! Đội trưởng sẽ liên hệ bạn.',
        ),
      ),
    );
  }

  void _changeLocation() {
    final districts = [
      'Quận Tân Bình, TP.HCM',
      'Quận 10, TP.HCM',
      'Quận 7, TP.HCM',
      'Quận Bình Thạnh, TP.HCM',
      'Quận Tân Phú, TP.HCM',
      'Quận Gò Vấp, TP.HCM',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Chọn khu vực của bạn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...districts.map(
                (d) => ListTile(
                  leading: const Icon(Iconsax.location, color: Color(0xFF16A34A)),
                  title: Text(d),
                  trailing: d == _currentLocation
                      ? const Icon(Icons.check_rounded, color: Color(0xFF16A34A))
                      : null,
                  onTap: () {
                    setState(() {
                      _currentLocation = d;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFacilityMapModal() {
    FacilityMapModal.show(
      context,
      currentLocationName: _currentLocation,
      onSelectFacility: (fac) {
        setState(() {
          _currentLocation = fac.address;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            content: Text('Đã chọn ${fac.name} làm cơ sở mặc định!'),
          ),
        );
      },
    );
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Iconsax.notification, color: Color(0xFF16A34A)),
                    SizedBox(width: 8),
                    Text(
                      'Thông báo hệ thống (FR19)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Iconsax.calendar_tick, color: Color(0xFF16A34A), size: 20),
                  ),
                  title: const Text('Booking đã xác nhận & Đặt cọc thành công', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Mã #FB-98214: Sân 7A lúc 20:00 (Kèm Trọng tài Standard & Giày thi đấu).'),
                  trailing: const Text('5p trước', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEF3C7),
                    child: Icon(Iconsax.cup, color: Color(0xFFD97706), size: 20),
                  ),
                  title: const Text('Giải Cúp Phủi Mùa Hè 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Lịch thi đấu Vòng bảng đã được Admin cập nhật. Xem chi tiết tại mục Giải Đấu.'),
                  trailing: const Text('1h trước', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Iconsax.shop, color: Color(0xFF0284C7), size: 20),
                  ),
                  title: const Text('Đơn mua nước & vớ thể thao sẵn sàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Đơn hàng của bạn đã sẵn sàng nhận tại quầy tiếp tân Cơ sở Quận 7.'),
                  trailing: const Text('2h trước', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await SecureStorageService.instance.clearAccessToken();
      if (AppConfig.isSupabaseConfigured) {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {}
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc tìm kiếm sân',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Loại sân', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _fieldFilterOptions.map((opt) {
                  final isSelected = _selectedFieldFilter == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    selectedColor: Colors.green.shade600,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedFieldFilter = opt;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 0: HOME DASHBOARD
  // -------------------------------------------------------------
  Widget _buildHomeDashboard() {
    return RefreshIndicator(
      color: Colors.green.shade600,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _fields = List.from(FieldModel.mockFields);
          _matches = List.from(MatchTeamModel.mockMatches);
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            HomeHeader(
              location: _currentLocation,
              onLocationTap: _changeLocation,
              onNotificationTap: _showNotificationSheet,
              onProfileTap: () => setState(() => _currentTabIndex = 4),
            ),
            const SizedBox(height: 8),

            // 2. Search Bar
            HomeSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onFilterTap: _showFilterModal,
              onClear: () => _onSearchChanged(''),
            ),
            const SizedBox(height: 16),

            // 3. Carousel Banner
            HomePromoBanner(
              onBannerTap: (index) {
                if (index == 0) {
                  setState(() => _currentTabIndex = 1);
                } else if (index == 1) {
                  TournamentModal.show(context);
                } else {
                  SportsStoreModal.show(context);
                }
              },
            ),
            const SizedBox(height: 20),

            // 4. Quick Actions (FR03-FR42)
            HomeQuickActions(
              onBookFieldTap: () => setState(() => _currentTabIndex = 1),
              onFacilityMapTap: _showFacilityMapModal,
              onRefereeEquipmentTap: () {
                if (_fields.isNotEmpty) {
                  _openBookingSheet(_fields.first);
                }
              },
              onSportsStoreTap: () => SportsStoreModal.show(context),
              onTournamentsTap: () => TournamentModal.show(context),
              onAIChatTap: () => AIChatModal.show(
                context,
                onBookNowTap: () => setState(() => _currentTabIndex = 1),
                onOpenMapTap: _showFacilityMapModal,
              ),
              onFindMatchTap: () => setState(() => _currentTabIndex = 2),
              onSplitBillTap: () => SplitBillDialog.show(context),
            ),
            const SizedBox(height: 20),

            // 5. Upcoming Match Card (if exists)
            if (_bookings.isNotEmpty) ...[
              UpcomingMatchCard(
                booking: _bookings.first,
                onTap: () => setState(() => _currentTabIndex = 3),
                onDirectionsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mở bản đồ dẫn đường đến ${_bookings.first.fieldName}'),
                    ),
                  );
                },
                onShareTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã sao chép liên kết mời đồng đội tham gia trận đấu!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // 6. Featured Fields Section
            FeaturedFieldsSection(
              fields: _fields,
              onSeeAllTap: () => setState(() => _currentTabIndex = 1),
              onFieldTap: _openBookingSheet,
              onBookTap: _openBookingSheet,
              onFavoriteToggle: _onFavoriteToggle,
            ),
            const SizedBox(height: 24),

            // 7. Match Finder Section
            MatchFinderSection(
              matches: _matches,
              onSeeAllTap: () => setState(() => _currentTabIndex = 2),
              onJoinMatchTap: _onJoinMatch,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: FIELDS LISTING & EXPLORATION
  // -------------------------------------------------------------
  Widget _buildFieldsTab() {
    final filtered = _selectedFieldFilter == 'Tất cả'
        ? _fields
        : _fields.where((f) => f.fieldTypes.contains(_selectedFieldFilter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám Phá Sân Bóng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sân bóng theo tên, khu vực...',
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _fieldFilterOptions.map((opt) {
                final isSelected = _selectedFieldFilter == opt;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    selectedColor: Colors.green.shade600,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedFieldFilter = opt),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không tìm thấy sân bóng phù hợp'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final field = filtered[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        clipBehavior: Clip.antiAlias,
                        elevation: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Image.network(
                                  field.imageUrl,
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    height: 140,
                                    color: Colors.green.shade100,
                                    child: const Center(
                                      child: Icon(Icons.sports_soccer, size: 48, color: Colors.green),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${field.distanceKm} km',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          field.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                          const SizedBox(width: 2),
                                          Text('${field.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    field.address,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: field.amenities.map((a) {
                                      return Chip(
                                        label: Text(a, style: const TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: Colors.grey.shade100,
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${field.pricePerHour} đ / giờ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade600,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => _openBookingSheet(field),
                                        child: const Text('Đặt sân'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: MATCHMAKING COMMUNITY (TÌM ĐỐI)
  // -------------------------------------------------------------
  Widget _buildMatchmakingTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cộng Đồng & Tìm Đối', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateMatchDialog();
        },
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo kèo mới'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final m = _matches[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(m.avatarUrl),
                        onBackgroundImageError: (_, _) {},
                        child: const Icon(Icons.sports_soccer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.teamName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Đội trưởng: ${m.captain} • SĐT: ${m.phone}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(m.level, style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Iconsax.clock, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text('${m.date} (${m.time})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(m.fieldSize, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.location, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text(m.fieldName, style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.feeRule, style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.w600, fontSize: 12)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: m.isJoined ? Colors.grey.shade400 : Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _onJoinMatch(m),
                        child: Text(m.isJoined ? 'Đã bắt kèo' : 'Bắt kèo ngay'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateMatchDialog() {
    final teamNameCtrl = TextEditingController(text: 'Đội bóng của tôi');
    final timeCtrl = TextEditingController(text: 'Tối nay 19:30');
    final fieldCtrl = TextEditingController(text: 'Sân Chảo Lửa');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng Kèo Tìm Đối'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: teamNameCtrl, decoration: const InputDecoration(labelText: 'Tên đội bóng')),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Thời gian thi đấu')),
            TextField(controller: fieldCtrl, decoration: const InputDecoration(labelText: 'Địa điểm sân')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _matches.insert(
                  0,
                  MatchTeamModel(
                    id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                    teamName: teamNameCtrl.text,
                    captain: 'Tôi',
                    phone: '0901234567',
                    date: 'Hôm nay',
                    time: timeCtrl.text,
                    fieldName: fieldCtrl.text,
                    fieldSize: 'Sân 7',
                    level: 'Giao lưu vui vẻ',
                    feeRule: 'Kèo 5-5',
                    avatarUrl: 'https://images.unsplash.com/photo-1511193311914-0346f16efe90?w=400&q=80',
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đăng bài tìm đối thủ thành công!')),
              );
            },
            child: const Text('Đăng kèo'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: USER BOOKINGS
  // -------------------------------------------------------------
  Widget _buildBookingsTab() {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch Đặt Của Tôi', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.green.shade700,
            indicatorColor: Colors.green.shade700,
            tabs: const [
              Tab(text: 'Sắp diễn ra'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Upcoming
            _bookings.isEmpty
                ? const Center(child: Text('Chưa có lịch đặt sắp tới'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mã: ${b.bookingCode}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Đã xác nhận',
                                      style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(b.fieldName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(b.subFieldName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Iconsax.calendar, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(b.date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              if (b.refereeName != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.sports, size: 14, color: Color(0xFF0D9488)),
                                    const SizedBox(width: 6),
                                    Text('Trọng tài: ${b.refereeName}', style: const TextStyle(fontSize: 12, color: Color(0xFF0D9488), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                              if (b.equipmentList.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.indigo),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Dụng cụ thuê: ${b.equipmentList.join(', ')}',
                                        style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    b.paymentOption == 'DEPOSIT'
                                        ? 'Đã cọc 30%: ${b.depositAmount}đ / ${b.totalAmount}đ'
                                        : 'Đã trả 100%: ${b.totalAmount}đ',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Chi tiết đặt sân ${b.bookingCode}')),
                                      );
                                    },
                                    child: const Text('Xem chi tiết'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            // Completed
            const Center(child: Text('Lịch sử các trận đấu đã hoàn thành')),
            // Cancelled
            const Center(child: Text('Không có lịch đặt đã hủy')),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: PROFILE & SETTINGS
  // -------------------------------------------------------------
  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Cầu Thủ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.redAccent),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green.shade600,
                    child: const Icon(Iconsax.user, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cầu Thủ Số 10',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'football.player@example.com',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Thành Viên Vàng ⭐',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('24', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                      SizedBox(height: 4),
                      Text('Trận đã đấu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('15', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                      SizedBox(height: 4),
                      Text('Bàn thắng', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('8', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                      SizedBox(height: 4),
                      Text('Lần MVP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action list
            ListTile(
              leading: const Icon(Iconsax.profile_2user, color: Color(0xFF16A34A)),
              title: const Text('Quản lý đội bóng của tôi'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Iconsax.heart, color: Colors.redAccent),
              title: const Text('Sân bóng đã lưu yêu thích'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Iconsax.card, color: Colors.blue),
              title: const Text('Lịch sử thanh toán & Nạp ví'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Iconsax.setting_2, color: Colors.grey),
              title: const Text('Cài đặt thông báo & Tài khoản'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Iconsax.logout, color: Colors.red),
              title: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => AIChatModal.show(
                context,
                onBookNowTap: () => setState(() => _currentTabIndex = 1),
                onOpenMapTap: _showFacilityMapModal,
              ),
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.smart_toy_rounded),
              label: const Text('AI Trợ lý', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeDashboard(),
            _buildFieldsTab(),
            _buildMatchmakingTab(),
            _buildBookingsTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'Đặt sân',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.profile_2user),
              label: 'Tìm đối',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.calendar_tick),
              label: 'Lịch đặt',
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.user),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}
