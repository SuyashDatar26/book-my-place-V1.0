import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'cascading_carousel.dart';
import 'chat_screen.dart';
import 'venue_detail_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> carouselImages = [
    'https://firebasestorage.googleapis.com/v0/b/project1-280af.appspot.com/o/LifeatLNCT-1.jpg?alt=media&token=5e43b101-2cd3-4090-8b8b-69b4e82f0337',
    'https://firebasestorage.googleapis.com/v0/b/project1-280af.appspot.com/o/Gayanarambh-4-1024x684.jpeg?alt=media&token=c6d25bf1-d868-49cc-b20f-a41d45b137d9',
    'https://firebasestorage.googleapis.com/v0/b/project1-280af.appspot.com/o/Auditorium-LNCT-Group-of-Colleges-1024x678-1.jpeg?alt=media&token=e13b48fc-3c9f-4483-a39c-69d7fa4c6ece',
  ];

  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _checkAndCreateDefaultVenues();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.deepPurpleAccent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _checkAndCreateDefaultVenues() async {
    CollectionReference venuesCollection = FirebaseFirestore.instance.collection('resources');
    QuerySnapshot snapshot = await venuesCollection.get();

    if (snapshot.docs.isEmpty) {
      await venuesCollection.doc('venue1').set({'name': 'Venue 1', 'capacity': 100});
      await venuesCollection.doc('venue2').set({'name': 'Venue 2', 'capacity': 200});
      await venuesCollection.doc('venue3').set({'name': 'Venue 3', 'capacity': 150});
      await venuesCollection.doc('venue4').set({'name': 'Venue 4', 'capacity': 300});
      await venuesCollection.doc('venue5').set({'name': 'Venue 5', 'capacity': 250});
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _initialLoad = _checkAndCreateDefaultVenues(); // re-trigger future
    });
    await _initialLoad;
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        title: const Text(
          'Book My Place',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFFFFFF),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurpleAccent),
                accountName: const Text('Welcome User', style: TextStyle(color: Colors.white)),
                accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? '', style: const TextStyle(color: Colors.white)),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.deepPurpleAccent),
                ),
              ),
              _drawerItem(Icons.person, 'Profile', '/profile'),
              _drawerItem(Icons.bookmark, 'My Bookings', '/myBookings'),
              _drawerItem(Icons.favorite, 'Favorites', '/favorites'),
              _drawerItem(Icons.info, 'About Us', '/aboutUs'),
              const Spacer(),
              _drawerItem(Icons.logout, 'Sign Out', '', isLogout: true),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('resources').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));

              var venues = snapshot.data!.docs;

              return RefreshIndicator(
                onRefresh: _refreshPage,
                color: Colors.deepPurpleAccent,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CascadingCarousel(carouselImages: carouselImages),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Venues',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (venues.isEmpty)
                      const Center(child: Text('No Venues Available', style: TextStyle(color: Colors.grey))),
                    ...venues.map((venue) {
                      final venueId = venue.id;
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('favorites')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('venues')
                            .doc(venueId)
                            .get(),
                        builder: (context, favSnapshot) {
                          final isFavorite = favSnapshot.data?.exists ?? false;

                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('resources')
                                .doc(venueId)
                                .collection('ratings')
                                .snapshots(),
                            builder: (context, ratingSnapshot) {
                              double avgRating = 0.0;

                              if (ratingSnapshot.hasData && ratingSnapshot.data!.docs.isNotEmpty) {
                                final ratings = ratingSnapshot.data!.docs
                                    .map((doc) => (doc['value'] as num?)?.toDouble() ?? 0.0)
                                    .toList();
                                avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
                              }

                              final averageRating = venue.data().containsKey('averageRating')
                                  ? (venue['averageRating'] as num?)?.toDouble()
                                  : null;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Material(
                                  elevation: 5,
                                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.red : Colors.grey,
                                                ),
                                                onPressed: () async {
                                                  final favRef = FirebaseFirestore.instance
                                                      .collection('favorites')
                                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                                      .collection('venues')
                                                      .doc(venueId);

                                                  if (isFavorite) {
                                                    await favRef.delete();
                                                  } else {
                                                    await favRef.set({'favoritedAt': Timestamp.now()});
                                                  }

                                                  setState(() {});
                                                },
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Capacity: ${venue['capacity'] ?? 'N/A'}',
                                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 20),
                                                  Text(
                                                    averageRating != null ? averageRating.toStringAsFixed(1) : 'N/A',
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                ],
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
                                                      builder: (context) => VenueDetailScreen(venueId: venueId),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepPurpleAccent,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                icon: const Icon(Icons.info_outline, color: Colors.white),
                                                label: const Text('View Details', style: TextStyle(color: Colors.white)),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatScreen(venueId: venueId),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                                                label: const Text('Chat', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, String routeName, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurpleAccent),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      onTap: () {
        if (isLogout) {
          _signOut();
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }
}
