import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  String _profileImageUrl = "";
  final picker = ImagePicker();

  int _totalBookings = 0;
  int _totalVenuesBooked = 0;

  @override
  void initState() {
    super.initState();
    _getUserProfileImage();
    _fetchBookingAnalytics();
  }

  Future<void> _getUserProfileImage() async {
    final User user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (snapshot.exists && snapshot.data() != null) {
      var userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _profileImageUrl = userData['profilePicture'] ?? '';
      });
    }
  }

  Future<void> _fetchBookingAnalytics() async {
    final User user = FirebaseAuth.instance.currentUser!;
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('user_id', isEqualTo: user.uid)
        .get();

    // Count total bookings and unique venues booked
    Set<String> venueIds = {};
    bookingsSnapshot.docs.forEach((doc) {
      venueIds.add(doc['venue_id']);
    });

    setState(() {
      _totalBookings = bookingsSnapshot.docs.length;
      _totalVenuesBooked = venueIds.length;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;
    final User user = FirebaseAuth.instance.currentUser!;
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}');
      await storageRef.putFile(_profileImage!);
      final imageUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profilePicture': imageUrl,
      });

      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      print("Failed to upload image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),  // Soft light background
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600,color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF4A148C),  // Rich purple background
        elevation: 4,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80,  // Slightly larger profile picture
                          backgroundColor: Colors.purpleAccent,
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : const AssetImage('assets/profile.png') as ImageProvider,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Information Card
                  _buildUserDetailCard(userData),

                  const SizedBox(height: 24),

                  // Booking Analytics Card
                  _buildBookingAnalyticsCard(),

                  const SizedBox(height: 24),

                  // Buttons for Edit and Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfileScreen(userData: userData)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),  // Purple button
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 6,
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              bool? confirmLogout = await _showLogoutDialog();
                              if (confirmLogout ?? false) {
                                FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),  // Violet button
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 6,
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDetailCard(Map<String, dynamic> userData) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _buildProfileDetail('Name', userData['name']),
            _buildProfileDetail('Email', FirebaseAuth.instance.currentUser?.email),
            _buildProfileDetail('College', userData['college']),
            _buildProfileDetail('Contact Number', userData['contactNumber']),
            _buildProfileDetail('Address', userData['address']),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value != null ? value.toString() : 'N/A',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingAnalyticsCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            _buildProfileDetail('Total Bookings', _totalBookings),
            _buildProfileDetail('Total Venues Booked', _totalVenuesBooked),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
