class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' ya 'expense'
  final String iconName;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconName,
  });

  // 1. Database (Supabase) se data model mein convert karne ke liye
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? 'Uncategorized',
      type: map['type'] ?? 'expense', // Agar kuch na mile toh default expense
      iconName: map['icon_name'] ?? 'category',
    );
  }

  // 2. Model se data Database mein bhejne ke liye (Insert/Update)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'icon_name': iconName,
      'user_id': userId,
    };
  }

  // 3. CopyWith method (Agar kabhi sirf ek field update karni ho)
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