import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'package:sih_project/l10n/app_localizations.dart';
import '../../services/firestore_service.dart';

class ClinicHomePage extends StatefulWidget {
  const ClinicHomePage({super.key});

  @override
  State<ClinicHomePage> createState() => _ClinicHomePageState();
}

class _ClinicHomePageState extends State<ClinicHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _patientCountController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedDisease;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // List of common water-borne diseases
  final List<String> _diseaseOptions = [
    'Cholera',
    'Typhoid Fever',
    'Hepatitis A',
    'Dysentery',
    'Giardiasis',
    'E. coli Infection',
    'Other'
  ];

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // --- NEW: Get l10n instance before async gap ---
      final l10n = AppLocalizations.of(context)!;

      try {
        await _firestoreService.saveClinicReport({
          'patient_count': int.parse(_patientCountController.text),
          'disease_type': _selectedDisease,
          'location': _locationController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Clear the form and show success message
        _formKey.currentState!.reset();
        _patientCountController.clear();
        _locationController.clear();
        setState(() {
          _selectedDisease = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Report Submitted Successfully"),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${l10n.failedToSubmitReport}: $e'),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _patientCountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clinicReport),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.newDiseaseReport,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedDisease,
                hint: Text(l10n.selectDiseaseType),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.sick_outlined),
                  labelText: l10n.diseaseType,
                ),
                items: _diseaseOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDisease = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? l10n.pleaseSelectDisease : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientCountController,
                decoration: InputDecoration(
                  labelText: l10n.numberOfPatients,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.group_add_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterPatientCount;
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.locationArea,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? l10n.pleaseEnterLocation : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitReport,
                      icon: const Icon(Icons.send),
                      label: Text(l10n.submitReport),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
