import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'venue_detail_screen.dart';
import 'chat_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .doc(userId)
            .collection('venues')
            .snapshots(),
        builder: (context, favSnapshot) {
          if (!favSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favDocs = favSnapshot.data!.docs;

          if (favDocs.isEmpty) {
            return const Center(child: Text('You have no favorite venues.'));
          }

          return ListView.builder(
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final venueId = favDocs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('resources')
                    .doc(venueId)
                    .get(),
                builder: (context, venueSnapshot) {
                  if (!venueSnapshot.hasData || !venueSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final venue = venueSnapshot.data!;
                  final averageRating = venue.data().toString().contains('averageRating')
                      ? (venue['averageRating'] as num?)?.toDouble()
                      : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  venue['name'] ?? 'Unnamed Venue',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('favorites')
                                      .doc(userId)
                                      .collection('venues')
                                      .doc(venueId)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Capacity: ${venue['capacity'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              Text(
                                averageRating != null
                                    ? averageRating.toStringAsFixed(1)
                                    : 'N/A',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VenueDetailScreen(venueId: venueId),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline,color: Colors.white,),
                                label: const Text('View Details',style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreen(venueId: venueId),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline,color: Colors.white,),
                                label: const Text('Chat',style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
