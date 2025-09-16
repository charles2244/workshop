class ProcurementDetails {
  final int id;
  final int quantity;
  final String remarks;
  final DateTime? receivedBy;
  final String? receivedImage;
  final int procurementId;

  ProcurementDetails({
    required this.id,
    required this.quantity,
    required this.remarks,
    this.receivedBy,
    this.receivedImage,
    required this.procurementId,
  });

  factory ProcurementDetails.fromJson(Map<String, dynamic> json) {
    DateTime? parsedReceivedBy;
    if (json['received_by'] != null && json['received_by'] is String) {
      parsedReceivedBy = DateTime.tryParse(json['received_by'] as String);
    }

    return ProcurementDetails(
      id: json['pd_id'] ?? 0,
      quantity: (json['quantity'] ?? 0).toInt(),
      remarks: json['remarks'] ?? '- ',
      receivedBy: parsedReceivedBy,
      receivedImage: json['received_image'] ?? ' ',
      procurementId: (json['procurement_id'] ?? 0) as int,
    );
  }
}