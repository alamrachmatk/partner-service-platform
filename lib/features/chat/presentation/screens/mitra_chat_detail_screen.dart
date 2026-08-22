import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/mitra_order_model.dart';
import 'mitra_chat_screen.dart';

// ── Model pesan ──
class _ChatMsg {
  final String text, time;
  final bool isMe;
  const _ChatMsg({required this.text, required this.isMe, required this.time});
}

class MitraChatDetailScreen extends StatefulWidget {
  final ChatInboxItem chat;
  const MitraChatDetailScreen({super.key, required this.chat});

  @override
  State<MitraChatDetailScreen> createState() => _MitraChatDetailScreenState();
}

class _MitraChatDetailScreenState extends State<MitraChatDetailScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _mitraTyping = false;

  late List<_ChatMsg> _messages;

  // Quick replies berbeda untuk order aktif vs konsultasi
  List<String> get _quickReplies {
    if (widget.chat.type == ChatType.activeOrder) {
      return [
        'Saya segera berangkat 🚗',
        'Mohon tunggu sebentar',
        'Saya sudah tiba di lokasi',
        'Pekerjaan selesai, terima kasih!',
      ];
    }
    return [
      'Halo, ada yang bisa saya bantu?',
      'Untuk informasi harga silakan lihat detail layanan',
      'Saya tersedia hari ini',
      'Silakan lakukan pemesanan',
    ];
  }

  @override
  void initState() {
    super.initState();
    _messages = _initMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  List<_ChatMsg> _initMessages() {
    if (widget.chat.type == ChatType.activeOrder) {
      return [
        _ChatMsg(text: 'Halo, pesanan saya sudah dikonfirmasi ya pak?',
            isMe: false, time: _timeAgo(30)),
        _ChatMsg(text: 'Iya betul, pesanan sudah saya terima. '
            'Saya akan datang sesuai jadwal ya.',
            isMe: true, time: _timeAgo(28)),
        _ChatMsg(text: 'Baik pak, ditunggu. Rumah saya yang ada pagar biru.',
            isMe: false, time: _timeAgo(25)),
        _ChatMsg(text: 'Siap, noted. Kalau ada yang perlu disiapkan?',
            isMe: true, time: _timeAgo(20)),
        _ChatMsg(text: 'Tidak ada pak, langsung saja. '
            'Oh iya AC yang bermasalah ada 2 unit ya.',
            isMe: false, time: _timeAgo(15)),
        _ChatMsg(text: widget.chat.lastMessage,
            isMe: false, time: _timeAgo(5)),
      ];
    }
    return [
      _ChatMsg(text: 'Halo pak, mau tanya soal servis AC.',
          isMe: false, time: _timeAgo(65)),
      _ChatMsg(text: widget.chat.lastMessage,
          isMe: false, time: _timeAgo(60)),
    ];
  }

  String _timeAgo(int minutesAgo) {
    final t = DateTime.now().subtract(Duration(minutes: minutesAgo));
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _timeNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send([String? text]) {
    final msg = (text ?? _msgCtrl.text).trim();
    if (msg.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(text: msg, isMe: true, time: _timeNow()));
      _msgCtrl.clear();
    });
    _scrollToBottom();

    // Auto-reply simulasi dari pelanggan
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _mitraTyping = true);
      _scrollToBottom();

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _mitraTyping = false;
          _messages.add(_ChatMsg(
            text: _autoReply(msg),
            isMe: false,
            time: _timeNow(),
          ));
        });
        _scrollToBottom();
      });
    });
  }

  String _autoReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('berangkat') || lower.contains('perjalanan')) {
      return 'Oke pak, saya tunggu di rumah ya 🙏';
    }
    if (lower.contains('tiba') || lower.contains('sampai')) {
      return 'Baik pak, saya bukakan pintunya sekarang!';
    }
    if (lower.contains('selesai') || lower.contains('terima kasih')) {
      return 'Terima kasih pak, hasilnya memuaskan! Nanti saya kasih bintang 5 ⭐';
    }
    if (lower.contains('harga') || lower.contains('biaya')) {
      return 'Baik pak, berapa estimasinya?';
    }
    if (lower.contains('tersedia') || lower.contains('bisa')) {
      return 'Alhamdulillah, boleh langsung saya pesan pak?';
    }
    return 'Baik pak, terima kasih infonya 🙏';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(
              widget.chat.customerName[0].toUpperCase(),
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Colors.white),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chat.customerName,
                  style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.chat.type.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(widget.chat.type.label,
                      style: TextStyle(fontSize: 9,
                          color: widget.chat.type.color,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 4),
                Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Online', style: TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
              ]),
            ],
          )),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(children: [
        // ── Info order (jika order aktif) ──
        if (widget.chat.order != null)
          _OrderBanner(order: widget.chat.order!),

        // ── Pesan ──
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: _messages.length + (_mitraTyping ? 1 : 0),
            itemBuilder: (_, i) {
              if (_mitraTyping && i == _messages.length) {
                return _TypingIndicator(name: widget.chat.customerName);
              }
              return _BubbleChat(msg: _messages[i]);
            },
          ),
        ),

        // ── Quick replies ──
        _QuickReplies(
          replies: _quickReplies,
          onSelect: (r) => _send(r),
        ),

        // ── Input ──
        _ChatInput(
          controller: _msgCtrl,
          onSend: () => _send(),
        ),
      ]),
    );
  }
}

// ── Banner info order ──
class _OrderBanner extends StatelessWidget {
  final MitraOrderModel order;
  const _OrderBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(order.serviceEmoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.serviceName, style: const TextStyle(fontSize: 12,
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${order.formattedDate} · ${order.formattedTime}',
                style: const TextStyle(fontSize: 11,
                    color: AppColors.textSecondary)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(order.status.label, style: const TextStyle(
              fontSize: 10, color: AppColors.primary,
              fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── Bubble chat ──
class _BubbleChat extends StatelessWidget {
  final _ChatMsg msg;
  const _BubbleChat({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                ),
                border: msg.isMe
                    ? null
                    : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(msg.text, style: TextStyle(
                  fontSize: 14, height: 1.4,
                  color: msg.isMe ? Colors.white : AppColors.textPrimary)),
            ),
            const SizedBox(height: 3),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(msg.time, style: const TextStyle(
                  fontSize: 10, color: AppColors.textHint)),
              if (msg.isMe) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Typing indicator ──
class _TypingIndicator extends StatefulWidget {
  final String name;
  const _TypingIndicator({required this.name});
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${widget.name} mengetik',
              style: const TextStyle(fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic)),
          const SizedBox(width: 8),
          FadeTransition(
            opacity: _anim,
            child: const Text('•••', style: TextStyle(fontSize: 16,
                color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

// ── Quick replies ──
class _QuickReplies extends StatelessWidget {
  final List<String> replies;
  final void Function(String) onSelect;
  const _QuickReplies({required this.replies, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onSelect(replies[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Center(child: Text(replies[i],
                style: const TextStyle(fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500))),
          ),
        ),
      ),
    );
  }
}

// ── Input chat ──
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: 4, minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Tulis pesan...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
