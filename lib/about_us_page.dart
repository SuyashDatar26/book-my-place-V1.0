import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6200EA), // Elegant purple
        elevation: 12.0, // More pronounced elevation for the app bar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding for better spacing
        child: SingleChildScrollView( // Allows scrolling for long content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Text(
                'Welcome to Our App!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6200EA),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Our app is designed to make managing your bookings seamless and effortless. Whether you\'re scheduling an event, managing resources, or keeping track of your bookings, our app provides a user-friendly interface to keep you organized. Our goal is to simplify the process and save you time!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 30),

              // Our Team Section
              const Text(
                'Our Team',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6200EA),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We are a passionate team of developers, designers, and innovators dedicated to building solutions that improve the user experience. Our team consists of:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- **Suyash Datar**: Lead Developer & UI/UX Specialist',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- **John Doe**: Backend Developer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- **Jane Smith**: Frontend Developer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '- **Michael Lee**: Designer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Contact Us Section
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6200EA),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'If you have any questions, feedback, or suggestions, feel free to reach out to us:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: contact@ourapp.com\n'
                    'Phone: +1 (123) 456-7890\n'
                    'Website: www.ourapp.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),

              // Get In Touch Button
              ElevatedButton(
                onPressed: () {
                  // Open a contact page or email app
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: const Size(double.infinity, 50), // Full width button
                  elevation: 8, // Elevation effect on button
                ),
                child: const Text(
                  'Get In Touch',
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
