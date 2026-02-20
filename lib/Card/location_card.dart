import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String name;
  final String properties;

  const LocationCard({
    super.key,
    required this.name,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_city, size: 30, color: Colors.green),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$properties properties',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
