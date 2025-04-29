import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VenueAdminHomeScreen extends StatefulWidget {
  const VenueAdminHomeScreen({super.key});

  @override
  State<VenueAdminHomeScreen> createState() => _VenueAdminHomeScreenState();
}

class _VenueAdminHomeScreenState extends State<VenueAdminHomeScreen> {
  String? selectedVenue;
  final List<String> venues = ['Venue A', 'Venue B', 'Venue C'];

  void _selectVenueDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Venue'),
        content: DropdownButtonFormField<String>(
          value: selectedVenue,
          items: venues.map((venue) {
            return DropdownMenuItem(
              value: venue,
              child: Text(venue),
            );
          }).toList(),
          onChanged: (value) {
            Navigator.of(context).pop(value);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedVenue = result;
      });
    }
  }

  void _requireVenue(VoidCallback onContinue) {
    if (selectedVenue == null) {
      _selectVenueDialog();
    } else {
      onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = const Color(0xFFF5F3FF); // light purple off-white
    final Color primary = const Color(0xFF7C3AED); // deep purple

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(selectedVenue == null
            ? 'Select Venue'
            : 'Venue Admin - $selectedVenue'),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.apartment),
            onPressed: _selectVenueDialog,
            tooltip: 'Change Venue',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Implement settings if needed
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Admin 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardTile(
                    icon: LucideIcons.calendarClock,
                    title: 'Manage Bookings',
                    onTap: () => _requireVenue(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ManageBookingsScreen(
                              venueName: selectedVenue!,
                            )),
                      );
                    }),
                    color: primary,
                  ),
                  _DashboardTile(
                    icon: LucideIcons.building,
                    title: 'Venue Details',
                    onTap: () => _requireVenue(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VenueDetailsScreen(
                              venueName: selectedVenue!,
                            )),
                      );
                    }),
                    color: Colors.deepPurpleAccent,
                  ),
                  _DashboardTile(
                    icon: LucideIcons.barChart3,
                    title: 'Analytics',
                    onTap: () => _requireVenue(() {
                      // Add AnalyticsScreen if needed
                    }),
                    color: Colors.purple,
                  ),
                  _DashboardTile(
                    icon: LucideIcons.messageCircle,
                    title: 'Customer Chat',
                    onTap: () => _requireVenue(() {
                      // Add ChatScreen if needed
                    }),
                    color: Colors.pinkAccent,
                  ),
                  _DashboardTile(
                    icon: LucideIcons.star,
                    title: 'Reviews',
                    onTap: () => _requireVenue(() {
                      // Add ReviewsScreen if needed
                    }),
                    color: Colors.amber,
                  ),
                  _DashboardTile(
                    icon: LucideIcons.penTool,
                    title: 'Edit Venue',
                    onTap: () => _requireVenue(() {
                      // Add EditVenueScreen if needed
                    }),
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageBookingsScreen extends StatelessWidget {
  final String venueName;
  const ManageBookingsScreen({super.key, required this.venueName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings - $venueName'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: Center(child: Text('Manage bookings for $venueName...')),
    );
  }
}

class VenueDetailsScreen extends StatelessWidget {
  final String venueName;
  const VenueDetailsScreen({super.key, required this.venueName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venue Details - $venueName'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
      body: Center(child: Text('Details for $venueName')),
    );
  }
}
