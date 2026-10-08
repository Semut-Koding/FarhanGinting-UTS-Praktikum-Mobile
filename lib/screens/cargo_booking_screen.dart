import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/fleet.dart';
import '../models/waybill.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/checkbox_group.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/fleet_photo.dart';
import '../widgets/section_card.dart';

class CargoBookingScreen extends StatefulWidget {
  const CargoBookingScreen({super.key, required this.fleet});

  final Fleet fleet;

  @override
  State<CargoBookingScreen> createState() => _CargoBookingScreenState();
}

class _CargoBookingScreenState extends State<CargoBookingScreen> {
  final TextEditingController _destinationController = TextEditingController();

  String _cargoCategory = DummyData.cargoCategories.first;
  Set<String> _protections = {};
  DateTime? _pickupDate;
  TimeOfDay? _departureTime;
  late double _tonnage;
  bool _reeferActive = false;

  static const double _minTonnage = 1;

  Fleet get fleet => widget.fleet;

  @override
  void initState() {
    super.initState();
    _tonnage = math.min(3, fleet.maxCapacityTon);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  int get _tonnageCost => (_tonnage * fleet.ratePerTon).round();
  int get _categoryCost => DummyData.categorySurcharge[_cargoCategory] ?? 0;
  int get _protectionCost => _protections.fold<int>(
    0,
    (sum, p) => sum + (DummyData.protectionServices[p] ?? 0),
  );
  int get _reeferCost => _reeferActive ? DummyData.reeferCost : 0;
  int get _totalCost =>
      fleet.baseRate +
      _tonnageCost +
      _categoryCost +
      _protectionCost +
      _reeferCost;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Pilih Tanggal Penjemputan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) setState(() => _pickupDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? const TimeOfDay(hour: 7, minute: 0),
      helpText: 'Estimasi Jam Keberangkatan Truk',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) setState(() => _departureTime = picked);
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _calculateCost() {
    FocusScope.of(context).unfocus();
    if (_destinationController.text.trim().isEmpty) {
      _showWarning('Kota tujuan pengiriman wajib diisi.');
      return;
    }
    if (_pickupDate == null || _departureTime == null) {
      _showWarning('Tentukan tanggal penjemputan & jam keberangkatan truk.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 500),
        reverseDuration: Duration(milliseconds: 300),
      ),
      builder: (sheetContext) => _CostSheet(
        fleet: fleet,
        destination: _destinationController.text.trim(),
        category: _cargoCategory,
        tonnage: _tonnage,
        pickupDate: _pickupDate!,
        departureTime: _departureTime!,
        items: [
          _CostItem('Tarif dasar ${fleet.name}', fleet.baseRate),
          _CostItem(
            'Tonase ${Fmt.ton(_tonnage)} × ${Fmt.rupiah(fleet.ratePerTon)}',
            _tonnageCost,
          ),
          if (_categoryCost > 0)
            _CostItem('Surcharge $_cargoCategory', _categoryCost),
          for (final p in _protections)
            _CostItem(p, DummyData.protectionServices[p]!),
          if (_reeferActive)
            _CostItem('Reefer Container', DummyData.reeferCost),
        ],
        total: _totalCost,
        onConfirm: () => _confirmIssue(sheetContext),
      ),
    );
  }

  Future<void> _confirmIssue(BuildContext sheetContext) async {
    final approved = await showAnimatedDialog<bool>(
      context: sheetContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.assignment_turned_in_rounded,
          color: AppColors.orange,
          size: 44,
        ),
        title: const Text('Terbitkan Surat Jalan?'),
        content: Text(
          'Surat jalan untuk armada ${fleet.name} tujuan '
          '${_destinationController.text.trim()} senilai '
          '${Fmt.rupiah(_totalCost)} akan diterbitkan. '
          'Data tidak dapat diubah setelah diterbitkan.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('approveIssueButton'),
            style: FilledButton.styleFrom(minimumSize: const Size(130, 44)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Terbitkan'),
          ),
        ],
      ),
    );

    if (approved != true || !mounted || !sheetContext.mounted) return;

    final now = DateTime.now();
    final result = Waybill(
      resiNumber:
          'CF-${now.year % 100}${now.month.toString().padLeft(2, '0')}-'
          '${(1000 + math.Random().nextInt(9000))}',
      fleetName: fleet.name,
      cargoCategory: _cargoCategory,
      tonnage: _tonnage,
      pickupDate: _pickupDate!,
      destination: _destinationController.text.trim(),
      totalCost: _totalCost,
      status: 'Surat Jalan Terbit',
      isNew: true,
    );

    Navigator.pop(sheetContext);
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: [
                _animated(0, _buildDestinationSection()),
                _animated(1, _buildCategorySection()),
                _animated(2, _buildProtectionSection()),
                _animated(3, _buildScheduleSection()),
                _animated(4, _buildLoadSection()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _animated(int index, Widget child) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 200 + index * 90),
      child: Padding(padding: const EdgeInsets.only(bottom: 14), child: child),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
      title: const Text('Booking Kargo'),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.paddingOf(context).top + kToolbarHeight + 4,
            20,
            16,
          ),
          child: Row(
            children: [
              Hero(
                tag: fleet.heroTag,
                child: FleetPhoto(fleet: fleet, size: 104, radius: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Armada dipilih',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      fleet.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${fleet.type} • ${fleet.plateNumber}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Kapasitas maks ${Fmt.ton(fleet.maxCapacityTon)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationSection() {
    return SectionCard(
      icon: Icons.place_outlined,
      title: 'Tujuan Pengiriman',
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: TextField(
          key: const Key('destinationField'),
          controller: _destinationController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Contoh: Surabaya',
            prefixIcon: const Icon(Icons.flag_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.orange, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    const icons = {
      'General Cargo': Icons.inventory_2_outlined,
      'Makanan Beku/Perishable': Icons.ac_unit_rounded,
      'Alat Berat': Icons.construction_rounded,
    };

    return SectionCard(
      icon: Icons.category_outlined,
      title: 'Kategori Muatan',
      child: RadioGroup<String>(
        groupValue: _cargoCategory,
        onChanged: (value) {
          if (value != null) setState(() => _cargoCategory = value);
        },
        child: Column(
          children: [
            for (final category in DummyData.cargoCategories)
              RadioListTile<String>(
                value: category,
                contentPadding: EdgeInsets.zero,
                title: Text(category),
                subtitle: Text(
                  DummyData.categorySurcharge[category] == 0
                      ? 'Tanpa biaya tambahan'
                      : '+ ${Fmt.rupiah(DummyData.categorySurcharge[category]!)}',
                ),
                secondary: AnimatedScale(
                  scale: _cargoCategory == category ? 1.2 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    icons[category],
                    color: _cargoCategory == category
                        ? AppColors.orange
                        : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionSection() {
    return SectionCard(
      icon: Icons.shield_outlined,
      title: 'Proteksi Pengiriman',
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          '${_protections.length} dipilih',
          key: ValueKey(_protections.length),
          style: const TextStyle(
            color: AppColors.orange,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      child: CheckboxGroup(
        options: DummyData.protectionServices.keys.toList(),
        selected: _protections,
        subtitles: DummyData.protectionServices.map(
          (key, value) => MapEntry(key, '+ ${Fmt.rupiah(value)}'),
        ),
        onChanged: (value) => setState(() => _protections = value),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return SectionCard(
      icon: Icons.event_note_outlined,
      title: 'Jadwal Pengambilan',
      child: Column(
        children: [
          const SizedBox(height: 4),
          _PickerTile(
            key: const Key('datePickerTile'),
            icon: Icons.calendar_month_rounded,
            label: 'Tanggal Penjemputan Barang',
            value: _pickupDate == null ? null : Fmt.date(_pickupDate!),
            placeholder: 'Pilih tanggal',
            onTap: _pickDate,
          ),
          const SizedBox(height: 10),
          _PickerTile(
            key: const Key('timePickerTile'),
            icon: Icons.schedule_rounded,
            label: 'Estimasi Jam Keberangkatan Truk',
            value: _departureTime == null ? null : Fmt.time(_departureTime!),
            placeholder: 'Pilih jam',
            onTap: _pickTime,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLoadSection() {
    final showReeferHint =
        _cargoCategory == 'Makanan Beku/Perishable' && !_reeferActive;

    return SectionCard(
      icon: Icons.tune_rounded,
      title: 'Pengaturan Muatan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(child: Text('Estimasi Tonase Muatan')),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Fmt.ton(_tonnage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _tonnage,
            min: _minTonnage,
            max: fleet.maxCapacityTon,
            divisions: ((fleet.maxCapacityTon - _minTonnage) * 2).round(),
            label: Fmt.ton(_tonnage),
            activeColor: AppColors.orange,
            onChanged: (value) => setState(() => _tonnage = value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min ${Fmt.ton(_minTonnage)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Maks ${Fmt.ton(fleet.maxCapacityTon)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 28),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _reeferActive
                    ? const Color(0xFF4FC3F7)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedRotation(
                turns: _reeferActive ? 0.5 : 0,
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.ac_unit_rounded,
                  color: _reeferActive ? Colors.white : Colors.grey,
                ),
              ),
            ),
            title: const Text('Mesin Pendingin (Reefer Container)'),
            subtitle: Text(
              _reeferActive
                  ? 'Aktif • suhu -18°C s.d. 4°C'
                  : '+ ${Fmt.rupiah(DummyData.reeferCost)}',
            ),
            trailing: Switch(
              key: const Key('reeferSwitch'),
              value: _reeferActive,
              activeTrackColor: AppColors.orange,
              onChanged: (value) => setState(() => _reeferActive = value),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: showReeferHint
                ? Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates_outlined,
                          color: AppColors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Muatan perishable disarankan memakai Reefer Container.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Estimasi Biaya',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: _totalCost.toDouble()),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      Fmt.rupiah(value),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const Key('calculateCostButton'),
            onPressed: _calculateCost,
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('Hitung Biaya Logistik'),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? AppColors.orange : Colors.grey.shade300,
              width: filled ? 1.5 : 1,
            ),
            color: filled
                ? AppColors.orange.withValues(alpha: 0.06)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, color: filled ? AppColors.orange : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        value ?? placeholder,
                        key: ValueKey(value),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: filled ? AppColors.navy : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_calendar_outlined,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostItem {
  const _CostItem(this.label, this.amount);

  final String label;
  final int amount;
}

class _CostSheet extends StatelessWidget {
  const _CostSheet({
    required this.fleet,
    required this.destination,
    required this.category,
    required this.tonnage,
    required this.pickupDate,
    required this.departureTime,
    required this.items,
    required this.total,
    required this.onConfirm,
  });

  final Fleet fleet;
  final String destination;
  final String category;
  final double tonnage;
  final DateTime pickupDate;
  final TimeOfDay departureTime;
  final List<_CostItem> items;
  final int total;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rincian Biaya Surat Jalan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    Icons.local_shipping_outlined,
                    'Armada',
                    '${fleet.name} (${fleet.plateNumber})',
                  ),
                  _summaryRow(
                    Icons.route_outlined,
                    'Rute',
                    'Depo Subang → $destination',
                  ),
                  _summaryRow(Icons.category_outlined, 'Kategori', category),
                  _summaryRow(Icons.scale_outlined, 'Tonase', Fmt.ton(tonnage)),
                  _summaryRow(
                    Icons.event_outlined,
                    'Jadwal',
                    '${Fmt.date(pickupDate)}, ${Fmt.time(departureTime)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < items.length; i++)
              FadeSlideIn(
                delay: Duration(milliseconds: 150 + i * 70),
                offset: const Offset(0.1, 0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(child: Text(items[i].label)),
                      Text(
                        Fmt.rupiah(items[i].amount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Biaya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => Text(
                    Fmt.rupiah(value),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('issueWaybillButton'),
              onPressed: onConfirm,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Terbitkan Surat Jalan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
