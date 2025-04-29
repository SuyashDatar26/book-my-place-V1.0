import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageVenuesScreen extends StatelessWidget {
  const ManageVenuesScreen({super.key});

  void _showVenueDialog(BuildContext context, {DocumentSnapshot? venue}) {
    final nameController = TextEditingController(text: venue?['name']);
    final capacityController = TextEditingController(
        text: venue != null ? venue['capacity'].toString() : '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(venue == null ? 'Add Venue' : 'Edit Venue'),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Venue Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final capacity = int.tryParse(capacityController.text.trim()) ?? 0;

              if (venue == null) {
                FirebaseFirestore.instance.collection('resources').add({
                  'name': name,
                  'capacity': capacity,
                });
              } else {
                venue.reference.update({
                  'name': name,
                  'capacity': capacity,
                });
              }
              Navigator.pop(context);
            },
            child: Text(venue == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Venues',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF5E35B1), // Deep Purple color
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E35B1),
        child: const Icon(Icons.add,color: Colors.white,),
        onPressed: () => _showVenueDialog(context),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final venues = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    venue['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Capacity: ${venue['capacity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF5E35B1)),
                        onPressed: () => _showVenueDialog(context, venue: venue),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text("Confirm Deletion"),
                              content: const Text("Are you sure you want to delete this venue?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    venue.reference.delete();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
