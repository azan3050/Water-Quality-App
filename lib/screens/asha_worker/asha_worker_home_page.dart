import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sih_project/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/ml_service.dart';
import '../../services/firestore_service.dart';

class AshaWorkerHomePage extends StatefulWidget {
  const AshaWorkerHomePage({super.key});

  @override
  _AshaWorkerHomePageState createState() => _AshaWorkerHomePageState();
}

class _AshaWorkerHomePageState extends State<AshaWorkerHomePage> {
  final _formKey = GlobalKey<FormState>();
  final MLService _mlService = MLService();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _predictionResult;

  // One controller for each feature + location
  final _locationController = TextEditingController();
  final List<TextEditingController> _featureControllers =
      List.generate(7, (index) => TextEditingController());

  // Labels for the text fields, in the correct order for the model
  final List<String> _featureLabels = [
    "ph(mean)",
    "fecal_coliform_(mpn/100ml)(max)",
    "total_coliform_(mpn/100ml)(max)",
    "dissolved_oxygen_(mg/l)(min)",
    "bod_(mg/l)(max)",
    "nitrate_n_(mg/l)(max)",
    "rainfall_(mm)"
  ];

  @override
  void initState() {
    super.initState();
    _mlService.loadModel().then((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _mlService.close();
    _locationController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _predictData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // --- NEW: Get l10n instance before async gap ---
      final l10n = AppLocalizations.of(context)!;

      try {
        // Collect inputs from controllers
        final inputs = _featureControllers
            .map((controller) => double.parse(controller.text))
            .toList();

        // Get prediction from the ML service
        final result = _mlService.predict(inputs);

        // Prepare data for Firestore
        final dataToSave = <String, dynamic>{
          'location': _locationController.text,
          'predictedClass': result,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Add each feature value with its name to the data map
        for (int i = 0; i < _featureLabels.length; i++) {
          // Create a more database-friendly key
          String key = _featureLabels[i].replaceAll(RegExp(r'[\(\)/]'),'').replaceAll('__', '_');
          dataToSave[key] = inputs[i];
        }

        // Save to Firestore
        await _firestoreService.savePrediction(dataToSave);

        setState(() {
          _predictionResult = result;
        });
      } catch (e) {
        // --- THIS IS THE NEW DEBUGGING LINE ---
        print('An error occurred during prediction: $e');
        // -----------------------------------------
        _showErrorDialog(l10n.failedToProcessPrediction);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    // --- NEW: Get l10n instance from the current context ---
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.anErrorOccurred),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.okay),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  Color _getPredictionColor(String? result) {
    switch (result) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return Colors.orange.shade400;
      case 'Low':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ashaWorkerPortal),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          )
        ],
      ),
      body: _isLoading && _predictionResult == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.enterWaterQualityData,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: l10n.location,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterLocation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_featureLabels.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          controller: _featureControllers[index],
                          decoration: InputDecoration(
                            labelText: _featureLabels[index],
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return l10n.pleaseEnterValidNumber;
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _predictData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(l10n.predictAndSave),
                      ),
                    if (_predictionResult != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Card(
                          color: _getPredictionColor(_predictionResult),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  l10n.predictionResult,
                                  style:  TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _predictionResult!,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
    );
  }
}
