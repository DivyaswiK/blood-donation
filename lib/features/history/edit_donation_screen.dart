import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDonationScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic> donation;
  final int index;

  const EditDonationScreen({
    super.key,
    required this.username,
    required this.donation,
    required this.index,
  });

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _landmarkController;
  late String _bloodGroup;
  DateTime? _availableDateTime;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    final location = widget.donation['location'] ?? {};
    _areaController = TextEditingController(text: location['area'] ?? '');
    _cityController = TextEditingController(text: location['city'] ?? '');
    _districtController = TextEditingController(text: location['district'] ?? '');
    _stateController = TextEditingController(text: location['state'] ?? '');
    _pincodeController = TextEditingController(text: location['pincode'] ?? '');
    _landmarkController = TextEditingController(text: location['landmark'] ?? '');
    _bloodGroup = widget.donation['bloodGroup'];
    _availableDateTime = DateTime.tryParse(widget.donation['availableDateTime'] ?? '');
  }

  Future<void> _pickDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableDateTime ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _availableDateTime = picked;
      });
    }
  }

  Future<void> _updateDonation() async {
    if (!_formKey.currentState!.validate() || _availableDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final updated = {
      'bloodGroup': _bloodGroup,
      'availableDateTime': _availableDateTime!.toIso8601String(),
      'location': {
        'area': _areaController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'landmark': _landmarkController.text,
      }
    };

    final url = Uri.parse('http://localhost:3000/donations/${widget.username}/${widget.index}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // go back to history screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update donation")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Donation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                items: _bloodGroups
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) => setState(() => _bloodGroup = val!),
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(_availableDateTime == null
                    ? 'Pick available date'
                    : 'Available: ${_availableDateTime!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 10),
              _buildTextField(_areaController, 'Area'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_districtController, 'District'),
              _buildTextField(_stateController, 'State'),
              _buildTextField(_pincodeController, 'Pincode'),
              _buildTextField(_landmarkController, 'Landmark', required: false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateDonation,
                child: const Text("Update Donation"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: required ? (v) => v == null || v.trim().isEmpty ? 'Enter $label' : null : null,
      ),
    );
  }
}
