import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController teacherIdController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedRole;
  final List<String> roles = ['Admin', 'Venue Admin', 'User'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('Book My Place', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.app_registration_rounded, size: 80, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join us and book your favorite venues effortlessly!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildTextField(nameController, 'Full Name', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(teacherIdController, 'Teacher ID', Icons.badge),
              const SizedBox(height: 16),
              _buildTextField(collegeController, 'College Name', Icons.school),
              const SizedBox(height: 16),
              _buildTextField(emailController, 'Email Address', Icons.email),
              const SizedBox(height: 16),
              _buildTextField(contactNumberController, 'Contact Number', Icons.phone),
              const SizedBox(height: 16),
              _buildTextField(passwordController, 'Password', Icons.lock, obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(confirmPasswordController, 'Confirm Password', Icons.lock_outline, obscureText: true),
              const SizedBox(height: 16),

              // 🔑 Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                  labelText: 'Select Role',
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurple.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (passwordController.text != confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }

                    if (selectedRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a role')),
                      );
                      return;
                    }

                    try {
                      UserCredential userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'name': nameController.text.trim(),
                        'teacherId': teacherIdController.text.trim(),
                        'college': collegeController.text.trim(),
                        'email': emailController.text.trim(),
                        'contactNumber': contactNumberController.text.trim(),
                        'role': selectedRole,
                      });

                      // Fetch role and redirect accordingly
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .get();

                      final role = userDoc['role'];

                      if (role == 'Admin') {
                        Navigator.pushReplacementNamed(context, '/adminHome');
                      } else if (role == 'User') {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (role == 'Venue Admin'){
                        Navigator.pushReplacementNamed(context, '/venueAdminHome');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration failed: ${e.toString()}')),
                      );
                    }
                  },

                  child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }
}
