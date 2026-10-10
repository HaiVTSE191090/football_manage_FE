import 'package:flutter/material.dart';

class AIChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final List<String>? actionButtons;

  const AIChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionButtons,
  });
}

class AIChatModal extends StatefulWidget {
  final VoidCallback? onBookNowTap;
  final VoidCallback? onOpenMapTap;

  const AIChatModal({
    super.key,
    this.onBookNowTap,
    this.onOpenMapTap,
  });

  static void show(
    BuildContext context, {
    VoidCallback? onBookNowTap,
    VoidCallback? onOpenMapTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AIChatModal(
        onBookNowTap: onBookNowTap,
        onOpenMapTap: onOpenMapTap,
      ),
    );
  }

  @override
  State<AIChatModal> createState() => _AIChatModalState();
}

class _AIChatModalState extends State<AIChatModal> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<AIChatMessage> _messages = [
    const AIChatMessage(
      text: 'Xin chào! Tôi là Trợ lý AI Quản lý Sân bóng ⚽.\nTôi đã kết nối trực tiếp với cơ sở dữ liệu hệ thống (sân trống, giá thuê, trọng tài, cơ sở). Bạn muốn tìm thông tin gì hôm nay?',
      isUser: false,
      timestamp: 'Vừa xong',
      actionButtons: ['Xem sân trống', 'Bảng giá sân', 'Tìm sân gần nhất'],
    ),
  ];

  final List<String> _quickPrompts = [
    'Hôm nay còn sân 5 nào trống?',
    'Sân nào gần tôi nhất?',
    'Sân 7 người giá bao nhiêu?',
    'Có trọng tài Standard rảnh tối nay không?',
    'Cơ sở Quận 7 mở cửa tới mấy giờ?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String query) async {
    final text = query.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        AIChatMessage(
          text: text,
          isUser: true,
          timestamp: 'Bây giờ',
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate backend POST /api/ai/chat query DB -> context -> AI answer
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final response = _generateDBAnswer(text);

    setState(() {
      _isTyping = false;
      _messages.add(response);
    });

    _scrollToBottom();
  }

  AIChatMessage _generateDBAnswer(String query) {
    final q = query.toLowerCase();

    if (q.contains('sân 5') || q.contains('5 người')) {
      return const AIChatMessage(
        text: '📊 [Dữ liệu Hệ thống]: Hiện tại Cơ sở Quận 7 còn Sân 5A và 5B trống khung giờ 17:30 - 19:00 và 20:30 - 22:00. Giá thuê niêm yết: 250.000đ - 280.000đ/giờ. Đã bao gồm đèn chiếu sáng tiêu chuẩn FIFA!',
        isUser: false,
        timestamp: 'Vừa xong',
        actionButtons: ['Đặt sân 5 ngay'],
      );
    } else if (q.contains('gần') || q.contains('khoảng cách')) {
      return const AIChatMessage(
        text: '📍 [Dữ liệu GPS & Cơ sở]: Bạn đang ở khu vực lân cận. Cơ sở gần bạn nhất là:\n• Football Center ABC - Cơ sở Quận 7 (cách 2.4 km)\n• Cơ sở Bình Thạnh (cách 3.6 km)\nBạn có muốn mở bản đồ chỉ đường không?',
        isUser: false,
        timestamp: 'Vừa xong',
        actionButtons: ['Xem bản đồ cơ sở'],
      );
    } else if (q.contains('giá') || q.contains('sân 7')) {
      return const AIChatMessage(
        text: '💰 [Bảng giá Hệ thống]:\n• Sân 5 người: 220.000đ - 280.000đ/giờ\n• Sân 7 người: 350.000đ - 420.000đ/giờ (VIP mặt cỏ ngoại nhập)\n• Sân 11 người: 800.000đ - 1.200.000đ/giờ.\nKhách hàng có thể chọn thanh toán cọc 30% để giữ sân!',
        isUser: false,
        timestamp: 'Vừa xong',
        actionButtons: ['Đặt sân ngay'],
      );
    } else if (q.contains('trọng tài') || q.contains('referee')) {
      return const AIChatMessage(
        text: '👨‍⚖️ [Dữ liệu Trọng tài]: Đang có 3 trọng tài sẵn sàng nhận trận tối nay:\n• Nguyễn Văn An (Level Standard - 150.000đ/giờ)\n• Trần Minh Quân (Level Pro - 220.000đ/giờ)\n• Lê Hoàng Nam (Level Basic - 100.000đ/giờ).\nBạn có thể thêm dịch vụ trọng tài trực tiếp trong lúc đặt sân!',
        isUser: false,
        timestamp: 'Vừa xong',
        actionButtons: ['Đặt sân kèm trọng tài'],
      );
    } else if (q.contains('mở cửa') || q.contains('quận 7') || q.contains('giờ')) {
      return const AIChatMessage(
        text: '🕒 [Thông tin Cơ sở]: Football Center ABC - Cơ sở Quận 7 mở cửa từ 06:00 sáng đến 23:30 tối tất cả các ngày trong tuần. Hotline hỗ trợ: 0909 123 456.',
        isUser: false,
        timestamp: 'Vừa xong',
      );
    } else {
      return AIChatMessage(
        text: '🤖 Dựa trên dữ liệu hệ thống, tôi đã ghi nhận câu hỏi "$query". Bạn có thể tra cứu lịch trống theo từng cơ sở, thuê trọng tài, thuê giày đá bóng hoặc xem giải đấu đang mở cổng đăng ký!',
        isUser: false,
        timestamp: 'Vừa xong',
        actionButtons: ['Xem sân trống', 'Bảng giá sân'],
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF16A34A), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AI Trợ Lý Quản Lý Sân',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 16),
                        ],
                      ),
                      Text(
                        'Truy vấn thời gian thực từ Database hệ thống',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF16A34A) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: !msg.isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.grey.shade900,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        if (msg.actionButtons != null && msg.actionButtons!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: msg.actionButtons!.map((act) {
                              return InkWell(
                                onTap: () {
                                  if (act.contains('sân')) {
                                    Navigator.pop(context);
                                    widget.onBookNowTap?.call();
                                  } else if (act.contains('bản đồ')) {
                                    Navigator.pop(context);
                                    widget.onOpenMapTap?.call();
                                  } else {
                                    _sendMessage(act);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF16A34A)),
                                  ),
                                  child: Text(
                                    act,
                                    style: const TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI đang truy vấn database hệ thống...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],

          // Quick Prompts row
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade100,
                  side: BorderSide(color: Colors.grey.shade300),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Hỏi AI về sân trống, giá, trọng tài...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF16A34A)),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
