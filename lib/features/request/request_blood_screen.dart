import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../match/matched_donors_screen.dart';
import 'my_requests_screen.dart';

class RequestBloodScreen extends StatefulWidget {
  final String username;
  const RequestBloodScreen({super.key, required this.username});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _bloodGroup;
  DateTime? _requiredDate;

  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _pincodeController = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _requiredDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate() || _bloodGroup == null || _requiredDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please complete all required fields')),
    );
    return;
  }

  final url = Uri.parse('http://localhost:3000/request');

  // ✅ FLAT PAYLOAD like Thunder Client
  final payload = {
    'username': widget.username,
    'bloodGroup': _bloodGroup,
    'patientName': _patientNameController.text.trim(),
    'hospitalName': _hospitalController.text.trim(),
    'contactNumber': _contactController.text.trim(),
    'dateOfRequirement': _requiredDate!.toIso8601String(),
    'location': {
      'state': _stateController.text.trim(),
      'district': _districtController.text.trim(),
      'city': _cityController.text.trim(),
      'area': _areaController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    }
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchedDonorsScreen(
            bloodGroup: _bloodGroup!,
            dateOfRequirement: _requiredDate!.toIso8601String(),
            state: _stateController.text.trim(),
            district: _districtController.text.trim(),
            patientName: _districtController.text.trim(),
            hospitalName: _districtController.text.trim(),
            contactNumber:_districtController.text.trim(),
            city: _cityController.text.trim(),
          ),
        ),
      );
    } else {
      final result = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Request submission failed')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  Widget _textField(TextEditingController controller, String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Enter $label' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) {
              if (value == 'viewRequests') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyRequestsScreen(username: widget.username),
                  ),
                );
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'viewRequests',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('View My Requests'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                items: _bloodGroups
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) => setState(() => _bloodGroup = val),
                decoration: const InputDecoration(
                  labelText: 'Required Blood Group',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Select blood group' : null,
              ),
              const SizedBox(height: 20),
              _textField(_patientNameController, 'Patient Name'),
              _textField(_hospitalController, 'Hospital Name'),
              _textField(_contactController, 'Contact Number'),
              _textField(_stateController, 'State'),
              _textField(_districtController, 'District'),
              _textField(_cityController, 'City'),
              _textField(_areaController, 'Area'),
              _textField(_pincodeController, 'Pincode'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _requiredDate == null
                      ? 'Select required date'
                      : 'Required on: ${_requiredDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
