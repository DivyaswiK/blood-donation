import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditRequestScreen extends StatefulWidget {
  final String username;
  final Map<String, dynamic> request;
  final int index;

  const EditRequestScreen({
    super.key,
    required this.username,
    required this.request,
    required this.index,
  });

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _patientName;
  late TextEditingController _hospital;
  late TextEditingController _contact;
  late TextEditingController _state;
  late TextEditingController _district;
  late TextEditingController _city;
  late TextEditingController _area;
  late TextEditingController _pincode;
  late String _bloodGroup;
  DateTime? _dateOfRequirement;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    final req = widget.request;
    final loc = req['location'] ?? {};
    _patientName = TextEditingController(text: req['patientName']);
    _hospital = TextEditingController(text: req['hospitalName']);
    _contact = TextEditingController(text: req['contactNumber']);
    _state = TextEditingController(text: loc['state']);
    _district = TextEditingController(text: loc['district']);
    _city = TextEditingController(text: loc['city']);
    _area = TextEditingController(text: loc['area']);
    _pincode = TextEditingController(text: loc['pincode']);
    _bloodGroup = req['bloodGroup'];
    _dateOfRequirement = DateTime.tryParse(req['dateOfRequirement']);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfRequirement ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _dateOfRequirement = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _dateOfRequirement == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    final updated = {
      'patientName': _patientName.text,
      'hospitalName': _hospital.text,
      'contactNumber': _contact.text,
      'bloodGroup': _bloodGroup,
      'dateOfRequirement': _dateOfRequirement!.toIso8601String(),
      'location': {
        'state': _state.text,
        'district': _district.text,
        'city': _city.text,
        'area': _area.text,
        'pincode': _pincode.text,
      }
    };

    final url = Uri.parse('http://localhost:3000/requests/${widget.username}/${widget.index}');
    final response = await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updated));

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update')));
    }
  }

  Widget _field(TextEditingController c, String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Enter $label' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Request')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _bloodGroup,
                items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                onChanged: (val) => setState(() => _bloodGroup = val!),
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              const SizedBox(height: 10),
              _field(_patientName, 'Patient Name'),
              _field(_hospital, 'Hospital Name'),
              _field(_contact, 'Contact Number'),
              _field(_state, 'State'),
              _field(_district, 'District'),
              _field(_city, 'City'),
              _field(_area, 'Area'),
              _field(_pincode, 'Pincode'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dateOfRequirement == null
                      ? 'Select required date'
                      : 'Required on: ${_dateOfRequirement!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text('Update Request')),
            ],
          ),
        ),
      ),
    );
  }
}
