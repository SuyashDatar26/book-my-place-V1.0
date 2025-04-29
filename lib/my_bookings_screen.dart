import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft gray background for clean UI
      appBar: AppBar(
        title: const Text('My Bookings',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF6200EA), // Elegant purple
        elevation: 8.0, // Subtle shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid) // Filter by userId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          var bookings = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index].data() as Map<String, dynamic>;
                String bookingId = bookings[index].id;

                return BookingCard(
                  venueName: booking['venueName'] ?? 'Unknown Venue',
                  date: booking['date'] ?? 'No Date',
                  time: booking['time'] ?? 'No Time',
                  purpose: booking['purpose'] ?? 'No Purpose',
                  department: booking['department'] ?? 'No Department',
                  onDelete: () => _showCancellationDialog(bookingId, booking),
                  onTap: () {
                    // Navigate to Booking Details screen (if applicable)
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCancellationDialog(String bookingId, Map<String, dynamic> booking) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for cancellation:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Reason',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () async {
                String reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reason is required to cancel the booking.')),
                  );
                  return;
                }

                try {
                  // Delete the booking
                  await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

                  // Update availability in the venue
                  await _updateAvailability(booking['venueId'] ?? '', booking['date'] ?? '', booking['time'] ?? '');

                  // Log cancellation details
                  await _logCancellation(booking, reason);

                  Navigator.of(context).pop(); // Close dialog after successful cancellation
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling booking: $e')));
                }
              },
              child: const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAvailability(String venueId, String date, String time) async {
    await FirebaseFirestore.instance.collection('bookings').add({
      'venue_id': venueId,
      'date': date,
      'time': time,
      'status': 'available',
    });
  }

  Future<void> _logCancellation(Map<String, dynamic> booking, String reason) async {
    await FirebaseFirestore.instance.collection('cancelledBookings').add({
      'userId': user.uid,
      'venueId': booking['venueId'] ?? 'Unknown Venue',
      'date': booking['date'] ?? 'No Date',
      'time': booking['time'] ?? 'No Time',
      'purpose': booking['purpose'] ?? 'No Purpose',
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class BookingCard extends StatelessWidget {
  final String venueName;
  final String date;
  final String time;
  final String purpose;
  final String department;
  final Function() onDelete;
  final Function() onTap;

  const BookingCard({
    super.key,
    required this.venueName,
    required this.date,
    required this.time,
    required this.purpose,
    required this.department,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.1),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Venue: $venueName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6200EA)),
              ),
              const SizedBox(height: 6),
              Text('Date: $date', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text('Time: $time', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Purpose: $purpose', style: const TextStyle(fontSize: 16)),
              Text('Department: $department', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
