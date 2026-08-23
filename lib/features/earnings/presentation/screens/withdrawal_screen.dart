import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/earnings_model.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _amountCtrl = TextEditingController();
  PaymentAccountModel? _selectedAccount;
  bool _loading = false;
  bool _success = false;

  static const _quickAmounts = [50000, 100000, 250000, 500000];

  double get _balance => DummyEarnings.balance;

  double get _enteredAmount =>
      double.tryParse(_amountCtrl.text.replaceAll('.', '')) ?? 0;

  bool get _isValid =>
      _selectedAccount != null &&
      _enteredAmount >= 50000 &&
      _enteredAmount <= _balance;

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  void _setAmount(double amount) {
    setState(() {
      _amountCtrl.text = amount.toInt().toString();
    });
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _loading = false; _success = true; });
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Konfirmasi Penarikan',
                style: TextStyle(fontWeight: FontWeight.w700)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Kamu akan menarik dana sebesar',
                  style: TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(_fmt(_enteredAmount), style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
              const SizedBox(height: 6),
              Text('ke ${_selectedAccount!.name} '
                  '${_selectedAccount!.maskedNumber}',
                  style: const TextStyle(fontSize: 13,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Dana akan masuk dalam 1x24 jam hari kerja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12,
                      color: AppColors.warning, height: 1.4),
                ),
              ),
            ]),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal', style: TextStyle(
                    color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ya, Tarik Dana',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _SuccessScreen(amount: _enteredAmount,
        account: _selectedAccount!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tarik Dana', style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16,
              100 + MediaQuery.of(context).padding.bottom),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            // ── Info saldo ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white70, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo Tersedia',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Text(_fmt(_balance), style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                  ],
                )),
                TextButton(
                  onPressed: () => _setAmount(_balance),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Tarik Semua',
                      style: TextStyle(fontSize: 12, color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // ── Nominal penarikan ──
            const Text('Nominal Penarikan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Minimal penarikan Rp 50.000',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _amountCtrl.text.isNotEmpty && !_isValid &&
                      _enteredAmount > 0
                      ? AppColors.error : AppColors.border,
                  width: _amountCtrl.text.isNotEmpty && !_isValid &&
                      _enteredAmount > 0 ? 1.5 : 0.5,
                ),
              ),
              child: Row(children: [
                const Text('Rp', style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 22,
                      fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 22, color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                )),
                if (_amountCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _amountCtrl.clear()),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textHint, size: 18),
                  ),
              ]),
            ),

            // Pesan error
            if (_amountCtrl.text.isNotEmpty && _enteredAmount > 0) ...[
              const SizedBox(height: 6),
              if (_enteredAmount < 50000)
                const Text('Minimal penarikan Rp 50.000',
                    style: TextStyle(fontSize: 11, color: AppColors.error))
              else if (_enteredAmount > _balance)
                const Text('Nominal melebihi saldo tersedia',
                    style: TextStyle(fontSize: 11, color: AppColors.error)),
            ],
            const SizedBox(height: 12),

            // Quick amount
            Wrap(spacing: 8, runSpacing: 8,
              children: _quickAmounts.map((a) => GestureDetector(
                onTap: () => _setAmount(a.toDouble()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _enteredAmount == a
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _enteredAmount == a
                          ? AppColors.primary : AppColors.border,
                      width: _enteredAmount == a ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(_fmt(a.toDouble()), style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: _enteredAmount == a
                          ? AppColors.primary : AppColors.textSecondary)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),

            // ── Pilih rekening ──
            const Text('Tujuan Penarikan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: List.generate(
                    DummyEarnings.accounts.length, (i) {
                  final acc = DummyEarnings.accounts[i];
                  final isSel = _selectedAccount?.id == acc.id;
                  final isLast = i == DummyEarnings.accounts.length - 1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAccount = acc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withOpacity(0.04)
                            : Colors.transparent,
                        border: !isLast
                            ? const Border(bottom: BorderSide(
                                color: AppColors.border, width: 0.5))
                            : null,
                      ),
                      child: Row(children: [
                        // Ikon bank/ewallet
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(
                            acc.type == 'bank' ? '🏦' : '💳',
                            style: const TextStyle(fontSize: 20),
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(acc.bankName, style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.textPrimary)),
                              if (acc.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Utama',
                                      style: TextStyle(fontSize: 9,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ]),
                            Text(acc.maskedNumber, style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        )),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary : AppColors.border,
                              width: isSel ? 5 : 1.5,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // ── Info estimasi ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: const Column(children: [
                Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: AppColors.info),
                  SizedBox(width: 8),
                  Expanded(child: Text('Informasi Penarikan',
                      style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w700, color: AppColors.info))),
                ]),
                SizedBox(height: 8),
                _InfoRow(label: 'Waktu proses', value: '1x24 jam kerja'),
                _InfoRow(label: 'Biaya transfer', value: 'Gratis'),
                _InfoRow(label: 'Minimal', value: 'Rp 50.000'),
                _InfoRow(label: 'Jam cut-off', value: '15:00 WIB'),
              ]),
            ),
          ]),
        ),

        // ── Tombol tarik ──
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20,
                12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(
                  color: AppColors.border, width: 0.5)),
            ),
            child: ElevatedButton(
              onPressed: (_isValid && !_loading) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      _isValid
                          ? 'Tarik ${_fmt(_enteredAmount)}'
                          : 'Masukkan nominal & pilih rekening',
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12,
              color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w600, color: AppColors.info)),
        ],
      ),
    );
  }
}

// ── Screen sukses ──
class _SuccessScreen extends StatelessWidget {
  final double amount;
  final PaymentAccountModel account;
  const _SuccessScreen({required this.amount, required this.account});

  String _fmt(double p) {
    if (p >= 1000000) return 'Rp ${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return 'Rp ${(p / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${p.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final refId = 'WD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  size: 48, color: AppColors.success),
            ),
            const SizedBox(height: 20),
            const Text('Penarikan Berhasil Diajukan!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Dana akan masuk ke rekeningmu\ndalam 1x24 jam hari kerja.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14,
                    color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(children: [
                _SuccessRow(label: 'ID Transaksi', value: refId,
                    valueColor: AppColors.primary),
                const Divider(height: 16),
                _SuccessRow(label: 'Nominal',
                    value: _fmt(amount), valueColor: AppColors.primary),
                const Divider(height: 16),
                _SuccessRow(label: 'Tujuan',
                    value: '${account.bankName} ${account.maskedNumber}'),
                const Divider(height: 16),
                _SuccessRow(label: 'Status',
                    value: '⏳ Diproses', valueColor: AppColors.warning),
                const Divider(height: 16),
                _SuccessRow(label: 'Estimasi',
                    value: '1x24 jam kerja'),
              ]),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .popUntil((r) => r.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Kembali ke Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SuccessRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _SuccessRow({required this.label, required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13,
            color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
