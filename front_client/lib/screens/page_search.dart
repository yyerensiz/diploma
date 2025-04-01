import 'package:flutter/material.dart';
import 'page_service_order.dart';
import 'page_specialist_profile.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Service',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          SearchBar(
            hintText: 'Search services or specialists',
            leading: Icon(Icons.search),
          ),
          SizedBox(height: 24),
          Text(
            'Services',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              ServiceCard(
                icon: Icons.directions_car,
                title: 'Child Transportation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailsPage(
                        serviceName: 'Child Transportation',
                      ),
                    ),
                  );
                },
              ),
              ServiceCard(
                icon: Icons.school,
                title: 'Homework Help',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailsPage(
                        serviceName: 'Homework Help',
                      ),
                    ),
                  );
                },
              ),
              ServiceCard(
                icon: Icons.home,
                title: 'Household Help',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceDetailsPage(
                        serviceName: 'Household Help',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Specialists',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return SpecialistCard(
                name: 'Anna M.',
                rating: 4.5,
                specialization: 'Babysitter',
                imageUrl: 'https://example.com/avatar.jpg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialistProfilePage(
                        name: 'Anna M.',
                        specialization: 'Babysitter',
                        rating: 4.5,
                        imageUrl: 'https://example.com/avatar.jpg',
                        description: 'Experienced babysitter with a passion for childcare.',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ServiceCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialistCard extends StatelessWidget {
  final String name;
  final double rating;
  final String specialization;
  final String imageUrl;
  final VoidCallback onTap;

  const SpecialistCard({
    required this.name,
    required this.rating,
    required this.specialization,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(specialization),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(rating.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
