import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final String username;

  const EditProfileScreen({super.key, required this.userProfile, required this.username});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late String _bloodGroup;
  DateTime? _lastDonated;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.userProfile['phone']);
    _bloodGroup = widget.userProfile['bloodGroup'] ?? '';
    if (widget.userProfile['lastDonatedAt'] != null) {
      _lastDonated = DateTime.tryParse(widget.userProfile['lastDonatedAt']);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonated ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _lastDonated = picked);
  }

  Future<void> _saveProfile() async {
    final url = Uri.parse('http://localhost:3000/profile/${widget.username}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "phone": _phoneController.text,
        "bloodGroup": _bloodGroup,
        "lastDonatedAt": _lastDonated?.toIso8601String()
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) => setState(() => _bloodGroup = val!),
                validator: (v) => v == null || v.isEmpty ? 'Select a blood group' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _lastDonated == null
                      ? 'Select Last Donation Date'
                      : 'Last Donated: ${_lastDonated!.toLocal().toString().split(" ")[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
