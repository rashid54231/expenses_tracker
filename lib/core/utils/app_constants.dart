import 'package:flutter/material.dart';

class AppCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  AppCategory({required this.id, required this.name, required this.icon, required this.color});
}

final List<AppCategory> expenseCategories = [
  AppCategory(id: 'food', name: 'Food', icon: Icons.fastfood, color: Colors.orange),
  AppCategory(id: 'transport', name: 'Transport', icon: Icons.directions_bus, color: Colors.blue),
  AppCategory(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag, color: Colors.pink),
  AppCategory(id: 'bills', name: 'Bills', icon: Icons.receipt, color: Colors.red),
];