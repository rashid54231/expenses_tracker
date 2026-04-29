class CategoryModel {
  final String id;        // Database ki Unique ID
  final String userId;    // User ki apni ID (RLS ke liye)
  final String name;      // Category ka naam (e.g., Taxi, Food)
  final String type;      // 'income' ya 'expense'
  final String iconName;  // Icon ka naam (Optional)

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconName,
  });

  // 1. Supabase (Map) se data Model mein convert karne ke liye
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      name: map['name'] ?? 'Uncategorized',
      type: map['type'] ?? 'expense', // Agar database mein type na ho toh expense rakhein
      iconName: map['icon_name'] ?? 'category',
    );
  }

  // 2. Model se data Map mein convert karne ke liye (Database mein bhejte waqt)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon_name': iconName,
      'user_id': userId,
    };
  }

  // 3. CopyWith method: Agar kisi category ki sirf ek cheez change karni ho
  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? iconName,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
    );
  }
}