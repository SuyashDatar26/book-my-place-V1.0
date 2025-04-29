import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  // Show a dialog to edit user details
  void _showEditDialog(BuildContext context, DocumentSnapshot user) {
    final userData = user.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: userData['name']);
    final roleController = TextEditingController(text: userData['role']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get updated data
              final name = nameController.text.trim();
              final role = roleController.text.trim();

              // Update user data in Firestore
              await FirebaseFirestore.instance.collection('users').doc(user.id).update({
                'name': name,
                'role': role,
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5E35B1), // Deep Purple color
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E35B1),
        child: const Icon(Icons.add),
        onPressed: () {
          // Implement adding a new user here if needed
        },
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              // Safely check if the 'role' field exists
              final email = userData['email'] ?? 'N/A';
              final role = userData.containsKey('role') && userData['role'] != null
                  ? userData['role']
                  : 'N/A';  // Fallback to 'N/A' if 'role' is missing or null
              final name = userData.containsKey('name') && userData['name'] != null
                  ? userData['name']
                  : 'N/A';  // Fallback to 'N/A' if 'name' is missing or null

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $name',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email: $email',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: $role',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFF5E35B1)),
                            onPressed: () {
                              _showEditDialog(context, user);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              _showDeleteConfirmationDialog(context, user.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Confirmation dialog before deleting a user
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(userId).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
