import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uts_praktikum/main.dart';

void main() {
  testWidgets('Alur lengkap CargoFlow: splash sampai surat jalan terbit',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    // 1. Splash screen -> onboarding
    await tester.pumpWidget(const CargoFlowApp());
    expect(find.text('LOGISTICS APP'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3300));
    await tester.pumpAndSettle();

    // 2. Onboarding -> login
    expect(find.text('Catat Manifes Muatan'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Armada yang Tepat'), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(find.text('Login Staf Lapangan'), findsOneWidget);

    // 3. Login salah -> AlertDialog
    await tester.enterText(find.byKey(const Key('staffIdField')), 'salah');
    await tester.enterText(find.byKey(const Key('passwordField')), '0000');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Login Gagal'), findsOneWidget);
    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    // 4. Login benar -> MainNavigationScreen
    await tester.enterText(find.byKey(const Key('staffIdField')), 'petugas');
    await tester.enterText(find.byKey(const Key('passwordField')), '1234');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Armada Tersedia'), findsOneWidget);
    expect(find.text('Colt Diesel'), findsOneWidget);

    // 5. Pilih armada -> CargoBookingScreen (passing data)
    await tester.tap(find.byKey(const Key('pilih-cdd')));
    await tester.pumpAndSettle();
    expect(find.text('Booking Kargo'), findsOneWidget);
    expect(find.text('Kapasitas maks 5,0 Ton'), findsOneWidget);

    // 6. Isi form
    final formScrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    ).first;
    Future<void> scrollTo(Finder finder) async {
      await tester.scrollUntilVisible(finder, 150, scrollable: formScrollable);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    await tester.enterText(
        find.byKey(const Key('destinationField')), 'Surabaya');
    await tester.tap(find.text('Makanan Beku/Perishable'));
    await tester.pumpAndSettle();

    final insurance = find.text('Asuransi Barang Rusak');
    await scrollTo(insurance);
    await tester.tap(insurance);
    await tester.pumpAndSettle();

    final dateTile = find.byKey(const Key('datePickerTile'));
    await scrollTo(dateTile);
    await tester.tap(dateTile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    final timeTile = find.byKey(const Key('timePickerTile'));
    await scrollTo(timeTile);
    await tester.tap(timeTile);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(find.text('07:00 WIB'), findsOneWidget);

    final reefer = find.byKey(const Key('reeferSwitch'));
    await scrollTo(reefer);
    await tester.tap(reefer);
    await tester.pumpAndSettle();

    // 7. Hitung biaya -> bottom sheet -> AlertDialog
    await tester.tap(find.byKey(const Key('calculateCostButton')));
    await tester.pumpAndSettle();
    expect(find.text('Rincian Biaya Surat Jalan'), findsOneWidget);
    expect(find.text('Reefer Container'), findsOneWidget);

    await tester.tap(find.byKey(const Key('issueWaybillButton')));
    await tester.pumpAndSettle();
    expect(find.text('Terbitkan Surat Jalan?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('approveIssueButton')));
    await tester.pumpAndSettle();

    // 8. Kembali ke layar utama (returning data) + SnackBar
    expect(find.text('Booking Kargo'), findsNothing);
    expect(find.textContaining('berhasil diterbitkan'), findsOneWidget);

    // 9. Resi baru muncul di Rekap Resi (DataTable)
    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.text('Surat Jalan Terbit'), findsOneWidget);

    // 10. Informasi Depo (SelectableText)
    await tester.tap(find.byIcon(Icons.warehouse_outlined));
    await tester.pumpAndSettle();
    expect(find.text('CFX-API-7F3A-91B2-SBG-2026'), findsOneWidget);

    // Biarkan SnackBar selesai agar tidak ada timer tertunda
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
