class SparePart {
  final int id;
  final String name;
  final String location;
  final int qty;
  final String imageUrl;

  SparePart({
    required this.id,
    required this.name,
    required this.location,
    required this.qty,
    required this.imageUrl,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['sp_id'] ?? 0,
      name: json['sp_name'] ?? 'Unknown',
      location: json['location'] ?? 'Unknown',
      qty: (json['qty'] ?? 0).toInt(),
      imageUrl: json['sp_image'] ?? 'assets/images/default.png',
    );
  }
}
