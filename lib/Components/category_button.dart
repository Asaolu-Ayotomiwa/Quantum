import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;

  const CategoryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[700],
            size: 28,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}