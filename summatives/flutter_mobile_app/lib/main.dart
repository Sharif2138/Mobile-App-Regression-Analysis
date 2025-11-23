import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AirlinePriceApp());
}

class AirlinePriceApp extends StatelessWidget {
  const AirlinePriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Airline Price Predictor',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const PredictionScreen(),
    );
  }
}

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _stopsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _daysLeftController = TextEditingController();

  String? _selectedAirline;
  String? _selectedDepartureTime;
  double? _predictedPrice;
  bool _loading = false;

  final List<String> airlines = [
    'Air_India',
    'GO_FIRST',
    'Indigo',
    'SpiceJet',
    'Vistara',
  ];

  final List<String> departureTimes = [
    'Early_Morning',
    'Morning',
    'Evening',
    'Late_Night',
    'Night',
  ];

  Map<String, int> encodeAirline(String airline) {
    return {
      'Air_India': airline == 'Air_India' ? 1 : 0,
      'GO_FIRST': airline == 'GO_FIRST' ? 1 : 0,
      'Indigo': airline == 'Indigo' ? 1 : 0,
      'SpiceJet': airline == 'SpiceJet' ? 1 : 0,
      'Vistara': airline == 'Vistara' ? 1 : 0,
    };
  }

  Map<String, int> encodeDeparture(String time) {
    return {
      'Early_Morning': time == 'Early_Morning' ? 1 : 0,
      'Morning': time == 'Morning' ? 1 : 0,
      'Evening': time == 'Evening' ? 1 : 0,
      'Late_Night': time == 'Late_Night' ? 1 : 0,
      'Night': time == 'Night' ? 1 : 0,
    };
  }

  Future<void> predictPrice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _predictedPrice = null;
    });

    final airlineMap = encodeAirline(_selectedAirline!);
    final departureMap = encodeDeparture(_selectedDepartureTime!);

    final Map<String, dynamic> payload = {
      "stops": int.parse(_stopsController.text),
      "duration": double.parse(_durationController.text),
      "days_left": int.parse(_daysLeftController.text),
      "airline_Air_India": airlineMap['Air_India'],
      "airline_GO_FIRST": airlineMap['GO_FIRST'],
      "airline_Indigo": airlineMap['Indigo'],
      "airline_SpiceJet": airlineMap['SpiceJet'],
      "airline_Vistara": airlineMap['Vistara'],
      "class_Economy": 1,
      "departure_time_Early_Morning": departureMap['Early_Morning'],
      "departure_time_Morning": departureMap['Morning'],
      "departure_time_Evening": departureMap['Evening'],
      "departure_time_Late_Night": departureMap['Late_Night'],
      "departure_time_Night": departureMap['Night'],
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictedPrice = data['predicted_price'];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Prediction failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error connecting to API!')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget buildInputCard(String label, Widget child) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Airline Price Predictor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildInputCard(
                'Number of Stops',
                TextFormField(
                  controller: _stopsController,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter number of stops' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 1',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              buildInputCard(
                'Duration (hours)',
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Please enter duration' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 2.5',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              buildInputCard(
                'Days Left to Travel',
                TextFormField(
                  controller: _daysLeftController,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter days left' : null,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 5',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              buildInputCard(
                'Select Airline',
                DropdownButtonFormField<String>(
                  value: _selectedAirline,
                  hint: const Text('Choose Airline'),
                  items: airlines
                      .map(
                        (airline) => DropdownMenuItem(
                          value: airline,
                          child: Text(airline),
                        ),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Select an airline' : null,
                  onChanged: (v) => setState(() => _selectedAirline = v),
                ),
              ),
              buildInputCard(
                'Select Departure Time',
                DropdownButtonFormField<String>(
                  value: _selectedDepartureTime,
                  hint: const Text('Choose Departure Time'),
                  items: departureTimes
                      .map(
                        (time) =>
                            DropdownMenuItem(value: time, child: Text(time)),
                      )
                      .toList(),
                  validator: (v) => v == null ? 'Select departure time' : null,
                  onChanged: (v) => setState(() => _selectedDepartureTime = v),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : predictPrice,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.flight_takeoff),
                  label: const Text('Predict Price'),
                ),
              ),
              const SizedBox(height: 24),
              if (_predictedPrice != null)
                Card(
                  color: Colors.indigo[50],
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Predicted Price: \$${_predictedPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
