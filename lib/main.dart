import 'package:book_my_place/profile_screen.dart';
import 'package:book_my_place/registration_screen.dart';
import 'package:book_my_place/venue_admin_home_screen.dart';
import 'package:book_my_place/admin_home_screen.dart'; // Import Admin screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Import all screens
import 'about_us_page.dart';
import 'booking_details_screen.dart';
import 'booking_screen.dart';
import 'confirmation_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Lock orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure Status Bar visibility is good
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Makes status bar background transparent
      statusBarIconBrightness: Brightness.light, // White icons for dark background (e.g., splash screen, home)
      statusBarBrightness: Brightness.dark, // For iOS
    ));

    return MaterialApp(
      title: 'Event Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const SplashScreen(),
      routes: {
        '/favorites': (context) => const FavoritesScreen(),

        '/aboutUs': (context)=>AboutUsScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/booking': (context) => BookingScreen(
          bookingDetails: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
          venueId: '',
          userId: '',
        ),
        '/confirmation': (context) => const ConfirmationScreen(bookingDetails: {}),
        '/profile': (context) => ProfileScreen(),
        '/myBookings': (context) => MyBookingsScreen(),
        '/bookingDetails': (context) => BookingDetailsScreen(
          bookingId: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/adminHome': (context) => AdminHomeScreen(),
        '/venueAdminHome': (context) => VenueAdminHomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _checkAuth();
  }

  void _startAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3)); // Show splash for 3 seconds

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // If user is not logged in, navigate to login screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        // User is authenticated, fetch their role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role']; // Assuming role field exists in the user document

          if (role == 'Admin') {
            // Navigate to Admin Home Screen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminHomeScreen()));
          } else if (role == 'Venue Admin') {
            // Navigate to Venue Admin Home Screen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => VenueAdminHomeScreen()));
          } else if(role == 'User') {
            // Regular user, navigate to Home Screen
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
          }
        } else {
          // If no user role found, navigate to login screen (edge case)
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensuring good status bar visibility for SplashScreen (White icons)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: Icon(
                    Icons.event_available,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Book My Place',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Gateway to Easy Event Booking',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
