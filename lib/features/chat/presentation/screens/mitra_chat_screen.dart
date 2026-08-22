import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';
import 'mitra_chat_detail_screen.dart';

enum ChatType { consultation, activeOrder }

extension ChatTypeX on ChatType {
  String get label {
    switch (this) {
      case ChatType.consultation: return 'Konsultasi';
      case ChatType.activeOrder:  return 'Order Aktif';
    }
  }
  Color get color {
    switch (this) {
      case ChatType.consultation: return AppColors.warning;
      case ChatType.activeOrder:  return AppColors.primary;
    }
  }
  IconData get icon {
    switch (this) {
      case ChatType.consultation: return Icons.help_outline_rounded;
      case ChatType.activeOrder:  return Icons.receipt_long_outlined;
    }
  }
}

class ChatInboxItem {
  final String id, customerName, lastMessage;
  final DateTime lastTime;
  final bool isRead;
  final ChatType type;
  final MitraOrderModel? order;
  final int unreadCount;

  const ChatInboxItem({
    required this.id, required this.customerName,
    required this.lastMessage, required this.lastTime,
    required this.type, this.isRead = false,
    this.order, this.unreadCount = 0,
  });
}

List<ChatInboxItem> _dummyInbox = [
  ChatInboxItem(
    id: 'CHT-001', customerName: 'Budi Santoso',
    lastMessage: 'Pak, saya tunggu di depan rumah ya 🙏',
    lastTime: DateTime.now().subtract(const Duration(minutes: 5)),
    type: ChatType.activeOrder, isRead: false, unreadCount: 2,
    order: DummyMitraOrders.all.firstWhere((o) => o.id == 'ORD-001'),
  ),
  ChatInboxItem(
    id: 'CHT-002', customerName: 'Ani Rahayu',
    lastMessage: 'Oke pak, ditunggu ya!',
    lastTime: DateTime.now().subtract(const Duration(minutes: 30)),
    type: ChatType.activeOrder, isRead: true, unreadCount: 0,
    order: DummyMitraOrders.all.firstWhere((o) => o.id == 'ORD-002'),
  ),
  ChatInboxItem(
    id: 'CHT-003', customerName: 'Sari Dewi',
    lastMessage: 'Berapa biaya servis AC 2 PK pak?',
    lastTime: DateTime.now().subtract(const Duration(hours: 1)),
    type: ChatType.consultation, isRead: false, unreadCount: 1,
  ),
  ChatInboxItem(
    id: 'CHT-004', customerName: 'Rudi Pratama',
    lastMessage: 'Apakah tersedia hari Sabtu?',
    lastTime: DateTime.now().subtract(const Duration(hours: 3)),
    type: ChatType.consultation, isRead: true, unreadCount: 0,
  ),
  ChatInboxItem(
    id: 'CHT-005', customerName: 'Hendra Wijaya',
    lastMessage: 'Terima kasih pak, hasilnya bagus!',
    lastTime: DateTime.now().subtract(const Duration(days: 1)),
    type: ChatType.activeOrder, isRead: true, unreadCount: 0,
  ),
];

class MitraChatScreen extends StatefulWidget {
  const MitraChatScreen({super.key});
  @override
  State<MitraChatScreen> createState() => _MitraChatScreenState();
}

class _MitraChatScreenState extends State<MitraChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  List<ChatInboxItem> get _all => _dummyInbox;
  List<ChatInboxItem> get _activeOrders =>
      _dummyInbox.where((c) => c.type == ChatType.activeOrder).toList();
  List<ChatInboxItem> get _consultations =>
      _dummyInbox.where((c) => c.type == ChatType.consultation).toList();
  int get _totalUnread =>
      _dummyInbox.fold(0, (sum, c) => sum + c.unreadCount);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _openChat(ChatInboxItem item) async {
    setState(() {
      final idx = _dummyInbox.indexWhere((c) => c.id == item.id);
      if (idx != -1) {
        _dummyInbox[idx] = ChatInboxItem(
          id: item.id, customerName: item.customerName,
          lastMessage: item.lastMessage, lastTime: item.lastTime,
          type: item.type, order: item.order,
          isRead: true, unreadCount: 0,
        );
      }
    });
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => MitraChatDetailScreen(chat: item),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Chat', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          if (_totalUnread > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.error,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$_totalUnread', style: const TextStyle(
                  fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Semua (${_all.length})'),
            Tab(text: 'Order (${_activeOrders.length})'),
            Tab(text: 'Konsultasi (${_consultations.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ChatList(items: _all, onTap: _openChat),
          _ChatList(items: _activeOrders, onTap: _openChat),
          _ChatList(items: _consultations, onTap: _openChat),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatInboxItem> items;
  final void Function(ChatInboxItem) onTap;
  const _ChatList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('💬', style: TextStyle(fontSize: 52)),
        SizedBox(height: 12),
        Text('Belum ada pesan', style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        SizedBox(height: 6),
        Text('Pesan dari pelanggan akan muncul di sini',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
      itemBuilder: (_, i) => _ChatTile(item: items[i], onTap: () => onTap(items[i])),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatInboxItem item;
  final VoidCallback onTap;
  const _ChatTile({required this.item, required this.onTap});

  String _fmtTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}j';
    if (diff.inDays < 7)     return '${diff.inDays}h';
    return '${t.day}/${t.month}';
  }

  @override
  Widget build(BuildContext context) {
    final unread = item.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Stack(children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(item.customerName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            Positioned(bottom: 0, right: 0,
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(color: item.type.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)),
                child: Icon(item.type.icon, size: 10, color: Colors.white),
              )),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(item.customerName, style: TextStyle(
                    fontSize: 14,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textPrimary))),
                Text(_fmtTime(item.lastTime), style: TextStyle(fontSize: 11,
                    color: unread ? AppColors.primary : AppColors.textHint,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w400)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: item.type.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(item.type.label, style: TextStyle(fontSize: 9,
                      color: item.type.color, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(item.lastMessage, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12,
                        color: unread ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: unread ? FontWeight.w500 : FontWeight.w400))),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          if (unread)
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Text('${item.unreadCount}', style: const TextStyle(
                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
            )
          else
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
        ]),
      ),
    );
  }
}
