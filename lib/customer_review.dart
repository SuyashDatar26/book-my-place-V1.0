import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> reviews = const [
    {'name': 'Alice', 'rating': 4, 'comment': 'Great venue!'},
    {'name': 'Bob', 'rating': 5, 'comment': 'Excellent service.'},
    {'name': 'Charlie', 'rating': 3, 'comment': 'Good, but can improve.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Reviews'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(review['name']),
              subtitle: Text(review['comment']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
