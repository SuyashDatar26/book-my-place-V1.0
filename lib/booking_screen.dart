import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui'; // For Blur Effect
import 'confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;
  final String venueId;

  const BookingScreen({super.key, required this.bookingDetails, required this.venueId, required String userId});

  Future<String> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return (userDoc.data() as Map<String, dynamic>)['name'] ?? 'Anonymous';
        } else {
          throw Exception('User document does not exist');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Error fetching user';
    }
  }

  Future<String> _fetchVenueName() async {
    try {
      DocumentSnapshot venueDoc = await FirebaseFirestore.instance.collection('resources').doc(venueId).get();
      return (venueDoc.data() as Map<String, dynamic>)['name'] ?? 'Unnamed Venue';
    } catch (e) {
      print("Error fetching venue name: $e");
      return 'Error fetching venue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5ECEF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple[600],
        centerTitle: true,
        title: const Text('Confirm Booking',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: Future.wait([_fetchUserName(), _fetchVenueName()]).then((values) => {
          'userName': values[0],
          'venueName': values[1],
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 5,
              ),
            );
          }

          String venueName = snapshot.data?['venueName'] ?? 'Unnamed Venue';
          String userName = snapshot.data?['userName'] ?? 'Anonymous';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '📅 Booking Details',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow('Venue', venueName),
                        const SizedBox(height: 10),
                        _buildDetailRow('Date', bookingDetails['date']),
                        const SizedBox(height: 10),
                        _buildDetailRow('Time', bookingDetails['time']),
                        const SizedBox(height: 10),
                        _buildDetailRow('Department', bookingDetails['department']),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (bookingDetails['purpose'].isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter the purpose of the event.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            try {
                              final user = FirebaseAuth.instance.currentUser;

                              await FirebaseFirestore.instance.collection('bookings').add({
                                'userId': user?.uid,
                                'venue_id': venueId,
                                'venueName': venueName,
                                'date': bookingDetails['date'],
                                'time': bookingDetails['time'],
                                'purpose': bookingDetails['purpose'],
                                'department': bookingDetails['department'],
                                'user_name': userName,
                                'created_at': FieldValue.serverTimestamp(),
                              });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmationScreen(bookingDetails: {
                                    'venueName': venueName,
                                    'date': bookingDetails['date'],
                                    'time': bookingDetails['time'],
                                    'purpose': bookingDetails['purpose'],
                                    'department': bookingDetails['department'],
                                  }),
                                ),
                              );
                            } catch (e) {
                              print("Error saving booking: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error saving booking.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                            backgroundColor: Colors.green.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                          ),
                          child: const Text('Confirm Booking', style: TextStyle(fontSize: 18,color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
