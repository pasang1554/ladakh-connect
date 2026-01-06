class AdModel {
  final String id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  final String location;
  final String category;
  final String sellerPhone;
  final DateTime postedAt;

  AdModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.sellerPhone,
    required this.postedAt,
  });

  // Convert from Firestore Document
  factory AdModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AdModel(
      id: documentId,
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      location: data['location'] ?? 'Ladakh',
      category: data['category'] ?? 'General',
      sellerPhone: data['sellerPhone'] ?? '',
      postedAt: data['postedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['postedAt']) 
          : DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'category': category,
      'sellerPhone': sellerPhone,
      'postedAt': postedAt.millisecondsSinceEpoch,
    };
  }
}
