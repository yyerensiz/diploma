import 'package:flutter/material.dart';
import 'order_details.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for services...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _serviceButton(context, 'Child Transport', Icons.directions_car),
                _serviceButton(context, 'Homework Help', Icons.book),
                _serviceButton(context, 'Household Help', Icons.cleaning_services),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceButton(BuildContext context, String label, IconData icon) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(serviceType: label), 
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50),
            Text(label),
          ],
        ),
      ),
    );
  }
}
