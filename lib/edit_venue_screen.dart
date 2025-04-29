import 'package:flutter/material.dart';

class EditVenueScreen extends StatefulWidget {
  const EditVenueScreen({Key? key}) : super(key: key);

  @override
  _EditVenueScreenState createState() => _EditVenueScreenState();
}

class _EditVenueScreenState extends State<EditVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _venueNameController = TextEditingController();
  final TextEditingController _venueAddressController = TextEditingController();
  final TextEditingController _venueCapacityController = TextEditingController();

  @override
  void dispose() {
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _venueCapacityController.dispose();
    super.dispose();
  }

  void _saveVenueDetails() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venue details saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Venue Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _venueNameController,
                decoration: InputDecoration(labelText: 'Venue Name'),
                validator: (value) => value!.isEmpty ? 'Please enter venue name' : null,
              ),
              TextFormField(
                controller: _venueAddressController,
                decoration: InputDecoration(labelText: 'Venue Address'),
                validator: (value) => value!.isEmpty ? 'Please enter venue address' : null,
              ),
              TextFormField(
                controller: _venueCapacityController,
                decoration: InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter capacity' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVenueDetails,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
