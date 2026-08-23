import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/earnings_model.dart';
import 'withdrawal_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _filterType = 'Semua';
  static const _filters = ['Semua', 'Pendapatan', 'Penarikan', 'Biaya'];

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  List<TransactionModel> get _filtered {
    if (_filterType == 'Semua') return DummyEarnings.transactions;
    if (_filterType == 'Pendapatan') {
      return DummyEarnings.transactions
          .where((t) => t.type == TransactionType.income).toList();
    }
    if (_filterType == 'Penarikan') {
      return DummyEarnings.transactions
          .where((t) => t.type == TransactionType.withdrawal).toList();
    }
    return DummyEarnings.transactions
        .where((t) => t.type == TransactionType.fee).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Pendapatan & Saldo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
                color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Header saldo ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(children: [
                // Saldo utama
                const Text('Saldo Tersedia',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(_fmt(DummyEarnings.balance),
                    style: const TextStyle(fontSize: 34,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: Colors.white60),
                  const SizedBox(width: 4),
                  Text('Dalam proses: ${_fmt(DummyEarnings.pendingBalance)}',
                      style: const TextStyle(fontSize: 12,
                          color: Colors.white70)),
                ]),
                const SizedBox(height: 20),

                // Statistik ringkasan
                Row(children: [
                  _SaldoStat(label: 'Bulan Ini',
                      value: _fmt(DummyEarnings.thisMonthEarnings)),
                  Container(width: 0.5, height: 36, color: Colors.white30),
                  _SaldoStat(label: 'Total Diterima',
                      value: _fmt(DummyEarnings.totalEarnings)),
                ]),
                const SizedBox(height: 20),

                // Tombol tarik dana
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const WithdrawalScreen())),
                    icon: const Icon(Icons.account_balance_rounded, size: 18),
                    label: const Text('Tarik Dana',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // ── Grafik bulanan ──
                _MonthlyChart(data: DummyEarnings.monthlyData,
                    labels: DummyEarnings.monthLabels, fmt: _fmt),
                const SizedBox(height: 16),

                // ── Filter & riwayat transaksi ──
                Row(children: [
                  const Text('Riwayat Transaksi',
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  Text('${_filtered.length} transaksi',
                      style: const TextStyle(fontSize: 12,
                          color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 10),

                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final sel = f == _filterType;
                      return GestureDetector(
                        onTap: () => setState(() => _filterType = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? AppColors.primary : AppColors.border,
                              width: sel ? 0 : 0.5,
                            ),
                          ),
                          child: Text(f, style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.textSecondary)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),

          // ── List transaksi ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _TransactionCard(transaction: _filtered[i]),
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Saldo stat ──
class _SaldoStat extends StatelessWidget {
  final String label, value;
  const _SaldoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 16,
          fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
    ]));
  }
}

// ── Grafik bulanan ──
class _MonthlyChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final String Function(double) fmt;
  const _MonthlyChart({required this.data, required this.labels,
      required this.fmt});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final total = data.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Pendapatan 6 Bulan Terakhir',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Spacer(),
          Text(fmt(total), style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.length, (i) {
              final ratio = data[i] / maxVal;
              final isLast = i == data.length - 1;
              return Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ✅ Semua bar tampilkan nominal, bukan hanya yang terakhir
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 3, vertical: 2),
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(fmt(data[i]),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 7,
                            color: isLast
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 72 * ratio,
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.25),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: TextStyle(
                      fontSize: 10,
                      color: isLast ? AppColors.primary : AppColors.textHint,
                      fontWeight: isLast ? FontWeight.w700 : FontWeight.w400)),
                ],
              ));
            }),
          ),
        ),
      ]),
    );
  }
}

// ── Card transaksi ──
class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionCard({required this.transaction});

  Color get _color {
    switch (transaction.type) {
      case TransactionType.income:     return AppColors.success;
      case TransactionType.withdrawal: return AppColors.info;
      case TransactionType.fee:        return AppColors.error;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(transaction.type.emoji,
                style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.description, style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(transaction.formattedDate, style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
            ],
          )),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(transaction.formattedAmount, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.success : AppColors.error)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textHint),
          ]),
        ]),
      ),
    );
  }
}

// ── Bottom sheet detail transaksi ──
class _TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionDetailSheet({required this.transaction});

  Color get _color {
    switch (transaction.type) {
      case TransactionType.income:     return AppColors.success;
      case TransactionType.withdrawal: return AppColors.info;
      case TransactionType.fee:        return AppColors.error;
    }
  }

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isIncome = transaction.type == TransactionType.income;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),

        // Ikon + nominal
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(transaction.type.emoji,
              style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 12),
        Text(transaction.type.label,
            style: const TextStyle(fontSize: 13,
                color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          '${isIncome ? '+' : '-'} ${_fmt(transaction.amount)}',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
              color: isIncome ? AppColors.success : AppColors.error),
        ),
        const SizedBox(height: 20),

        // Detail info
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: [
            _DetailRow(label: 'ID Transaksi', value: transaction.id,
                valueColor: AppColors.primary),
            const Divider(height: 16),
            _DetailRow(label: 'Keterangan', value: transaction.description),
            if (transaction.orderId != '-') ...[
              const Divider(height: 16),
              _DetailRow(label: 'ID Order', value: transaction.orderId,
                  valueColor: AppColors.primary),
            ],
            const Divider(height: 16),
            _DetailRow(label: 'Tanggal', value: transaction.formattedDate),
            const Divider(height: 16),
            _DetailRow(label: 'Status', value: '✅ Berhasil',
                valueColor: AppColors.success),
          ]),
        ),
        const SizedBox(height: 20),

        // Tombol tutup
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Tutup',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary),
            textAlign: TextAlign.right)),
      ],
    );
  }
}
