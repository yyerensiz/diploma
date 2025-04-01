import 'package:flutter/material.dart';

class ChooseSpecialistScreen extends StatelessWidget {
  final List<Map<String, String>> specialists = [
    {'name': 'Alice Smith', 'verified': 'Yes'},
    {'name': 'Bob Johnson', 'verified': 'No'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose a Specialist')),
      body: ListView.builder(
        itemCount: specialists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(specialists[index]['name']!),
            subtitle: Text('Verified: ${specialists[index]['verified']}'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SpecialistProfileScreen()));
            },
          );
        },
      ),
    );
  }
}

class SpecialistProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Specialist Profile')),
      body: Column(
        children: [
          CircleAvatar(radius: 50, backgroundColor: Colors.green),
          SizedBox(height: 10),
          Text('Alice Smith', style: TextStyle(fontSize: 20)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              print('Order sent to specialist');
            },
            child: Text('Order Service'),
          ),
        ],
      ),
    );
  }
}
