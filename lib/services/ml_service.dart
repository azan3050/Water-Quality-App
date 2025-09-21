import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  late Interpreter _interpreter;

  // --- SCALER PARAMETERS ---
  final Map<String, Map<String, double>> _scalerParams = {
    'ph(mean)': {'min': 6.582334, 'max': 8.530599},
    'fecal_coliform_(mpn/100ml)(max)': {'min': 0.0, 'max': 3985.5928},
    'total_coliform_(mpn/100ml)(max)': {'min': 0.0, 'max': 9645.0},
    'dissolved_oxygen_(mg/l)(min)': {'min': 0.2, 'max': 10.6},
    'bod_(mg/l)(max)': {'min': 0.1, 'max': 12.124382},
    'nitrate_n_(mg/l)(max)': {'min': 0.0, 'max': 11.36},
    'rainfall_(mm)': {'min': 100.0, 'max': 1199.0},
  };
  
  final List<String> _featureOrder = [
    'ph(mean)',
    'fecal_coliform_(mpn/100ml)(max)',
    'total_coliform_(mpn/100ml)(max)',
    'dissolved_oxygen_(mg/l)(min)',
    'bod_(mg/l)(max)',
    'nitrate_n_(mg/l)(max)',
    'rainfall_(mm)',
  ];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ann_model.tflite');
    } catch (e) {
      print("Failed to load model: $e");
      // --- THIS IS THE CRUCIAL CHANGE ---
      // Rethrow the error so the UI can catch it and display a message.
      rethrow;
    }
  }

  String predict(List<double> rawInputs) {
    var scaledInputs = List<double>.filled(rawInputs.length, 0);
    for (int i = 0; i < rawInputs.length; i++) {
      String featureName = _featureOrder[i];
      double min = _scalerParams[featureName]!['min']!;
      double max = _scalerParams[featureName]!['max']!;
      scaledInputs[i] = (rawInputs[i] - min) / (max - min);
    }

    var input = [scaledInputs];
    var output = List.filled(1 * 3, 0).reshape([1, 3]);

    _interpreter.run(input, output);

    List<double> probabilities = output[0];
    int maxIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[maxIndex]) {
        maxIndex = i;
      }
    }
    
    const classNames = ['Low', 'Medium', 'High']; 
    return classNames[maxIndex];
  }

  void close() {
    _interpreter.close();
  }
}

