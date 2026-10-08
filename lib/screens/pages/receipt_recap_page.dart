import 'package:flutter/material.dart';

import '../../models/waybill.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/fade_slide_in.dart';

class ReceiptRecapPage extends StatelessWidget {
  const ReceiptRecapPage({super.key, required this.waybills});

  final List<Waybill> waybills;

  Color _statusColor(String status) {
    switch (status) {
      case 'Terkirim':
        return AppColors.success;
      case 'Dalam Perjalanan':
        return AppColors.blue;
      case 'Surat Jalan Terbit':
        return AppColors.orange;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTonnage = waybills.fold<double>(0, (s, w) => s + w.tonnage);
    final totalCost = waybills.fold<int>(0, (s, w) => s + w.totalCost);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FadeSlideIn(
          child: Row(
            children: [
              _StatCard(
                icon: Icons.receipt_long_rounded,
                label: 'Total Resi',
                value: '${waybills.length}',
                color: AppColors.navy,
              ),
              const SizedBox(width: 10),
              _StatCard(
                icon: Icons.scale_rounded,
                label: 'Total Tonase',
                value: Fmt.ton(totalTonnage),
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: Row(
            children: [
              _StatCard(
                icon: Icons.payments_rounded,
                label: 'Nilai Pengiriman',
                value: Fmt.rupiah(totalCost),
                color: AppColors.orange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Data Surat Jalan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Geser tabel ke samping untuk melihat seluruh kolom',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.navy.withValues(alpha: 0.06),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('No. Resi')),
                      DataColumn(label: Text('Tujuan')),
                      DataColumn(label: Text('Armada')),
                      DataColumn(label: Text('Kategori')),
                      DataColumn(label: Text('Tonase'), numeric: true),
                      DataColumn(label: Text('Tgl Jemput')),
                      DataColumn(label: Text('Biaya'), numeric: true),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: waybills.map((w) {
                      final color = _statusColor(w.status);
                      return DataRow(
                        color: w.isNew
                            ? WidgetStateProperty.all(
                                AppColors.amber.withValues(alpha: 0.18),
                              )
                            : null,
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Text(
                                  w.resiNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (w.isNew) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.fiber_new_rounded,
                                    color: AppColors.orange,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          DataCell(Text(w.destination)),
                          DataCell(Text(w.fleetName)),
                          DataCell(Text(w.cargoCategory)),
                          DataCell(Text(Fmt.ton(w.tonnage))),
                          DataCell(Text(Fmt.date(w.pickupDate))),
                          DataCell(Text(Fmt.rupiah(w.totalCost))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                w.status,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color,
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
}
