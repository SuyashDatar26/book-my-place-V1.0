import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_venues_screen.dart';
import 'manage_users_screen.dart';
import 'booking_analytics_screen.dart';
import 'profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int venueCount = 0;
  int userCount = 0;
  int bookingCount = 0;
  bool isLoading = true;
  DateTime? lastUpdated;

  final Color primaryColor = const Color(0xFF5E35B1); // Deep Purple
  final Color backgroundColor = const Color(0xFFF8F8FA); // Off-white
  final Color cardColor = Color(0xFFEDE7F6); // Light Lavender

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    setState(() => isLoading = true);
    try {
      final venues = await FirebaseFirestore.instance.collection('resources').get();
      final users = await FirebaseFirestore.instance.collection('users').get();
      final bookings = await FirebaseFirestore.instance.collection('bookings').get();

      setState(() {
        venueCount = venues.size;
        userCount = users.size;
        bookingCount = bookings.size;
        lastUpdated = DateTime.now();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchCounts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Welcome Admin 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            if (lastUpdated != null)
              Text(
                'Last updated: ${lastUpdated!.toLocal()}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dashboardCard('Venues', Icons.location_city, venueCount.toString()),
                _dashboardCard('Users', Icons.people, userCount.toString()),
                _dashboardCard('Bookings', Icons.event, bookingCount.toString()),
              ],
            ),
            const SizedBox(height: 30),
            _adminButton(
              label: 'Manage Venues',
              icon: Icons.location_on,
              destination: const ManageVenuesScreen(),
            ),
            _adminButton(
              label: 'Manage Users',
              icon: Icons.supervised_user_circle,
              destination: const ManageUsersScreen(),
            ),
            _adminButton(
              label: 'Booking Analytics',
              icon: Icons.bar_chart,
              destination: const BookingAnalyticsScreen(),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Admin Panel • v1.0',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: primaryColor),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _adminButton({
    required String label,
    required IconData icon,
    required Widget destination,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
        icon: Icon(icon, color: Colors.white),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(radius: 30, backgroundColor: Colors.white),
                SizedBox(height: 10),
                Text('Admin User', style: TextStyle(color: Colors.white, fontSize: 16)),
                Text('admin@example.com', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
