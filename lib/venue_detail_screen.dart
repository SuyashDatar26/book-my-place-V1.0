import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';




class VenueDetailScreen extends StatefulWidget {
  final String venueId;


  const VenueDetailScreen({super.key, required this.venueId});

  @override
  _VenueDetailScreenState createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  DateTime selectedDate = DateTime.now();
  TextEditingController purposeController = TextEditingController();
  TextEditingController reviewController = TextEditingController();
  int selectedRating = 5;  // Default rating set to 5
  Map<String, bool> availability = {
    '9 AM - 11 AM': false,
    '11 AM - 1 PM': false,
    '1 PM - 3 PM': false,
    '3 PM - 5 PM': false,
  };
  String? selectedTimeSlot;
  String? selectedDepartment;
  List<String> departments = [];

  @override
  void initState() {
    super.initState();
    _checkAvailability();
    _fetchDepartments();
    _loadUserRating(); // <- add this
  }


  Future<void> _fetchDepartments() async {
    var departmentCollection = FirebaseFirestore.instance.collection('departments');
    var departmentDocs = await departmentCollection.get();

    if (departmentDocs.docs.isEmpty) {
      await departmentCollection.add({'name': 'Marketing'});
      await departmentCollection.add({'name': 'Sales'});
      await departmentCollection.add({'name': 'HR'});
      await departmentCollection.add({'name': 'IT'});
      departmentDocs = await departmentCollection.get();
    }

    setState(() {
      departments = departmentDocs.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _checkAvailability() async {
    var availabilityDocs = await FirebaseFirestore.instance
        .collection('bookings')
        .where('venue_id', isEqualTo: widget.venueId)
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        .get();

    availability.forEach((timeSlot, _) {
      availability[timeSlot] = availabilityDocs.docs.any((doc) => doc['time'] == timeSlot);
    });

    setState(() {});
  }

  Future<void> _selectDate(DateTime date) async {
    selectedDate = date;
    await _checkAvailability();
  }

  Future<void> _showUnavailableBookingDetails(String timeSlot) async {
    var bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .where('venue_id', isEqualTo: widget.venueId)
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        .where('time', isEqualTo: timeSlot)
        .limit(1)
        .get();

    if (bookingDoc.docs.isNotEmpty) {
      var booking = bookingDoc.docs.first.data();
      String bookedBy = booking['user_name'] ?? 'Unknown';
      String purpose = booking['purpose'] ?? 'No purpose provided';
      String department = booking['department'] ?? 'No department specified';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.all(20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
            title: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text('Already Booked', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 Booked by: $bookedBy', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('🎯 Purpose: $purpose', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 8),
                Text('🏢 Department: $department', style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );

    }
  }

  void _selectTimeSlot(String timeSlot) {
    if (purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the purpose of the event.')),
      );
      return;
    }

    if (selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department.')),
      );
      return;
    }

    if (selectedTimeSlot != timeSlot) {
      selectedTimeSlot = timeSlot;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            bookingDetails: {
              'date': DateFormat('yyyy-MM-dd').format(selectedDate),
              'time': timeSlot,
              'purpose': purposeController.text,
              'department': selectedDepartment,
            },
            venueId: widget.venueId,
            userId: '',
          ),
        ),
      );
    }
  }

  void _submitReview() async {
    if (reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    // Add the review (multiple per user allowed)
    await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.venueId)
        .collection('reviews')
        .add({
      'text': reviewController.text,
      'rating': selectedRating,
      'timestamp': Timestamp.now(),
      'userId': currentUser!.uid,
      'userEmail': currentUser?.email,
    });

    // Upsert the user's rating (only one per user)
    await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.venueId)
        .collection('ratings')
        .doc(currentUser?.uid)
        .set({
      'rating': selectedRating,
      'userId': currentUser?.uid,
      'userEmail': currentUser?.email,
      'timestamp': Timestamp.now(),
    });

    // Update the average rating
    var ratingDocs = await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.venueId)
        .collection('ratings')
        .get();

    double avgRating = 0.0;
    if (ratingDocs.docs.isNotEmpty) {
      avgRating = ratingDocs.docs.fold(0.0, (sum, doc) => sum + (doc['rating'] as int)) / ratingDocs.docs.length;
    }

    await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.venueId)
        .update({'averageRating': avgRating});

    reviewController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!')),
    );

    setState(() {});
  }


  void _loadUserRating() async {
    var ratingDoc = await FirebaseFirestore.instance
        .collection('resources')
        .doc(widget.venueId)
        .collection('ratings')
        .doc(currentUser!.uid)
        .get();

    if (ratingDoc.exists) {
      setState(() {
        selectedRating = ratingDoc['rating'];
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Venue Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen(venueId: widget.venueId)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('resources').doc(widget.venueId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Venue not found', style: TextStyle(color: Colors.black)));
          }

          var venue = snapshot.data!.data() as Map<String, dynamic>;
          var venueName = venue['name'] ?? "Unnamed Venue";
          var capacity = venue['capacity']?.toString() ?? "N/A";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    venueName,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text('Capacity: $capacity', style: TextStyle(fontSize: 18, color: Colors.black54)),
                ),
                const SizedBox(height: 20),
                _buildCalendar(),
                const SizedBox(height: 20),
                _buildPurposeInput(),
                const SizedBox(height: 20),
                _buildDepartmentDropdown(),
                const SizedBox(height: 30),
                _buildSectionTitle('Time Slots'),
                const SizedBox(height: 10),
                _buildTimeSlotsGrid(),
                const SizedBox(height: 30),
                _buildSectionTitle('Reviews'),
                const SizedBox(height: 10),
                _buildReviewSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: selectedDate,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selected, focused) {
          setState(() {
            selectedDate = selected;
            _checkAvailability();
          });
        },
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }

  Widget _buildPurposeInput() {
    return TextField(
      controller: purposeController,
      decoration: const InputDecoration(
        hintText: 'Enter purpose of event',
        prefixIcon: Icon(Icons.event_note),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDepartment,
      hint: const Text('Select Department'),
      items: departments.map((dept) {
        return DropdownMenuItem(value: dept, child: Text(dept));
      }).toList(),
      onChanged: (value) => setState(() => selectedDepartment = value),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: availability.keys.map((timeSlot) {
        bool isBooked = availability[timeSlot]!;
        return GestureDetector(
          onTap: () {
            if (isBooked) {
              _showUnavailableBookingDetails(timeSlot);
            } else {
              _selectTimeSlot(timeSlot);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isBooked ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBooked ? Colors.red[800] : Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: reviewController,
          decoration: const InputDecoration(
            hintText: 'Write your review...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          ),
        ),
        const SizedBox(height: 10),
        _buildStarRating(),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('resources')
              .doc(widget.venueId)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            var reviews = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: reviews.length,
                itemBuilder: (context, index) {
                  var reviewDoc = reviews[index];
                  var review = reviewDoc.data() as Map<String, dynamic>;
                  bool isOwner = review['userId'] == currentUser?.uid;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(review['userEmail'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['text'] ?? ''),
                          const SizedBox(height: 4),
                          Text('⭐ ${review['rating']} Stars'),
                        ],
                      ),
                      trailing: isOwner
                          ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('resources')
                              .doc(widget.venueId)
                              .collection('reviews')
                              .doc(reviewDoc.id)
                              .delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review deleted')),
                          );
                          setState(() {});
                        },
                      )
                          : null,
                    ),
                  );
                }

            );
          },
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              selectedRating = index + 1;
            });
          },
        );
      }),
    );
  }
}
