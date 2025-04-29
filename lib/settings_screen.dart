import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User user = FirebaseAuth.instance.currentUser!;
  late String _name;
  late String _email;
  late String _college;
  late String _contactNumber;
  late String _address;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Get user data from Firestore
  Future<void> _getUserData() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (snapshot.exists) {
      var userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _name = userData['name'] ?? 'No Name'; // Default value if null
        _email = user.email ?? 'No Email'; // Default value if null
        _college = userData['college'] ?? 'No College'; // Default value if null
        _contactNumber = userData['contactNumber'] ?? 'No Contact'; // Default value if null
        _address = userData['address'] ?? 'No Address'; // Default value if null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A), // Purple app bar color
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              ListTile(
                title: Text(_name), // Ensure name is not null
                subtitle: Text(_email), // Ensure email is not null
                leading: CircleAvatar(
                  backgroundColor: Colors.purpleAccent,
                  backgroundImage: NetworkImage('https://example.com/profile_picture'), // Replace with your profile image URL
                  radius: 30,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit profile screen
                  },
                ),
              ),
              const SizedBox(height: 24),

              // User Details Section
              Card(
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Name', _name),
                      _buildDetailRow('Email', _email),
                      _buildDetailRow('College', _college),
                      _buildDetailRow('Contact Number', _contactNumber),
                      _buildDetailRow('Address', _address),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Edit Profile
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 6,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create profile details rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
