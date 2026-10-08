import 'package:flutter/material.dart';

import '../models/fleet.dart';
import '../models/hazmat_guide.dart';
import '../models/waybill.dart';

class DummyData {
  DummyData._();

  static const String staffId = 'petugas';
  static const String password = '1234';

  static const String staffName = 'Petugas Lapangan';
  static const String fleetUnit = 'Unit Armada CF-07 • Depo Subang';
  static const String fleetPlate = 'T 9021 KX';

  static const String depotName = 'Depo Utama CargoFlow Subang';
  static const String depotAddress =
      'Jl. Raya Kalijati KM 12, Kawasan Industri Subang, Jawa Barat 41271';
  static const String depotPhone = '(0260) 417 777';
  static const String depotEmail = 'ops.subang@cargoflow.co.id';
  static const String depotCode = 'DPO-SBG-001';
  static const String trackingApiCode = 'CFX-API-7F3A-91B2-SBG-2026';
  static const String trackingEndpoint =
      'https://api.cargoflow.co.id/v1/tracking';

  static const List<Fleet> fleets = [
    Fleet(
      id: 'cdd',
      name: 'Colt Diesel',
      type: 'CDD Box • 6 Roda',
      plateNumber: 'T 8712 KA',
      maxCapacityTon: 5,
      ratePerTon: 175000,
      baseRate: 650000,
      dimension: '4,3 × 2,0 × 2,0 m',
      available: 6,
      color: Color(0xFF1D4E89),
      imageAsset: 'assets/images/colt_diesel.jpg',
    ),
    Fleet(
      id: 'fuso',
      name: 'Fuso',
      type: 'Fuso Wingbox • 6 Roda',
      plateNumber: 'T 9044 KB',
      maxCapacityTon: 10,
      ratePerTon: 150000,
      baseRate: 1100000,
      dimension: '6,0 × 2,4 × 2,4 m',
      available: 4,
      color: Color(0xFFF77F00),
      imageAsset: 'assets/images/fuso.jpg',
    ),
    Fleet(
      id: 'tronton',
      name: 'Tronton',
      type: 'Tronton Wingbox • 10 Roda',
      plateNumber: 'T 9188 KC',
      maxCapacityTon: 20,
      ratePerTon: 125000,
      baseRate: 1750000,
      dimension: '9,5 × 2,5 × 2,5 m',
      available: 2,
      color: Color(0xFF2A9D8F),
      imageAsset: 'assets/images/tronton.jpg',
    ),
  ];

  static const List<String> cargoCategories = [
    'General Cargo',
    'Makanan Beku/Perishable',
    'Alat Berat',
  ];

  static const Map<String, int> categorySurcharge = {
    'General Cargo': 0,
    'Makanan Beku/Perishable': 350000,
    'Alat Berat': 750000,
  };

  static const Map<String, int> protectionServices = {
    'Asuransi Barang Rusak': 250000,
    'Jasa Forklift Muat': 300000,
    'Pengawalan Prioritas': 500000,
  };

  static const int reeferCost = 450000;

  static List<HazmatGuide> hazmatGuides() => [
    HazmatGuide(
      unClass: 'Kelas 2',
      title: 'Gas Bertekanan (LPG, Oksigen)',
      icon: Icons.propane_tank_outlined,
      color: const Color(0xFF2A9D8F),
      rules: [
        'Tabung wajib diikat tegak dengan strap pengaman.',
        'Katup harus tertutup dan dilengkapi tutup pelindung.',
        'Dilarang merokok dalam radius 10 meter dari armada.',
        'Pasang placard UN Kelas 2 di sisi kiri, kanan, dan belakang truk.',
      ],
    ),
    HazmatGuide(
      unClass: 'Kelas 3',
      title: 'Cairan Mudah Terbakar (BBM, Thinner)',
      icon: Icons.local_fire_department_outlined,
      color: const Color(0xFFD62828),
      rules: [
        'Gunakan drum/jerigen bersertifikat UN dan tidak bocor.',
        'Armada wajib membawa minimal 2 unit APAR 6 kg.',
        'Jauhkan dari sumber panas dan percikan listrik.',
        'Pengemudi harus memiliki sertifikat B3 yang masih berlaku.',
      ],
    ),
    HazmatGuide(
      unClass: 'Kelas 8',
      title: 'Bahan Korosif (Asam, Aki)',
      icon: Icons.science_outlined,
      color: const Color(0xFFF77F00),
      rules: [
        'Kemasan wajib tahan korosi dan diberi label korosif.',
        'Sediakan spill kit dan bahan penetral di kabin.',
        'Petugas muat memakai sarung tangan & kacamata pelindung.',
        'Pisahkan dari bahan makanan dan muatan Kelas 3.',
      ],
    ),
    HazmatGuide(
      unClass: 'Kelas 9',
      title: 'Baterai Lithium & Bahan Lain-lain',
      icon: Icons.battery_alert_outlined,
      color: const Color(0xFF6A4C93),
      rules: [
        'Terminal baterai harus diisolasi untuk mencegah korsleting.',
        'Kemasan tidak boleh rusak, penyok, atau menggembung.',
        'Suhu ruang muat dijaga di bawah 35°C.',
        'Lampirkan MSDS (Material Safety Data Sheet) pada surat jalan.',
      ],
    ),
  ];

  static List<Waybill> initialWaybills() => [
    Waybill(
      resiNumber: 'CF-2610-0412',
      fleetName: 'Tronton',
      cargoCategory: 'Alat Berat',
      tonnage: 18,
      pickupDate: DateTime(2026, 10, 1),
      destination: 'Cikarang',
      totalCost: 5250000,
      status: 'Terkirim',
    ),
    Waybill(
      resiNumber: 'CF-2610-0418',
      fleetName: 'Fuso',
      cargoCategory: 'General Cargo',
      tonnage: 7.5,
      pickupDate: DateTime(2026, 10, 3),
      destination: 'Bandung',
      totalCost: 2225000,
      status: 'Dalam Perjalanan',
    ),
    Waybill(
      resiNumber: 'CF-2610-0425',
      fleetName: 'Colt Diesel',
      cargoCategory: 'Makanan Beku/Perishable',
      tonnage: 4,
      pickupDate: DateTime(2026, 10, 5),
      destination: 'Karawang',
      totalCost: 2150000,
      status: 'Dalam Perjalanan',
    ),
    Waybill(
      resiNumber: 'CF-2610-0431',
      fleetName: 'Fuso',
      cargoCategory: 'General Cargo',
      tonnage: 9,
      pickupDate: DateTime(2026, 10, 7),
      destination: 'Semarang',
      totalCost: 2450000,
      status: 'Menunggu Muat',
    ),
  ];
}
