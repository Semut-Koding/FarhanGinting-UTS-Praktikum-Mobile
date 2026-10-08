class Waybill {
  const Waybill({
    required this.resiNumber,
    required this.fleetName,
    required this.cargoCategory,
    required this.tonnage,
    required this.pickupDate,
    required this.destination,
    required this.totalCost,
    required this.status,
    this.isNew = false,
  });

  final String resiNumber;
  final String fleetName;
  final String cargoCategory;
  final double tonnage;
  final DateTime pickupDate;
  final String destination;
  final int totalCost;
  final String status;

  final bool isNew;
}
