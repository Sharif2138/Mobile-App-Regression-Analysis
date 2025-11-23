// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
  PredictionScreenState createState() => PredictionScreenState();
}

class PredictionScreenState extends State<PredictionScreen> {
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
        Uri.parse(
          'https://mobile-app-regression-analysis.onrender.com/predict',
        ),
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
        ).showSnackBar(const SnackBar(content: Text('Prediction failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error connecting to API!')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget buildInputField(String label, Widget field) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: field,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101844), Color(0xFF19287B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.flight_takeoff, color: Colors.white, size: 60),
                    SizedBox(height: 8),
                    Text(
                      'Airline Price Predictor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Numeric Inputs
                    Row(
                      children: [
                        buildInputField(
                          'Stops',
                          TextFormField(
                            controller: _stopsController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter stops';
                              final val = int.tryParse(v);
                              if (val == null || val < 0 || val > 3) {
                                return '0-3 only';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '0-3',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        buildInputField(
                          'Duration',
                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter duration' : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'hours',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        buildInputField(
                          'Days Left',
                          TextFormField(
                            controller: _daysLeftController,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter days left' : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'days',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Dropdowns
                    Row(
                      children: [
                        buildInputField(
                          'Airline',
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedAirline,
                            hint: const Text('Choose'),
                            items: airlines
                                .map(
                                  (airline) => DropdownMenuItem(
                                    value: airline,
                                    child: Text(airline),
                                  ),
                                )
                                .toList(),
                            validator: (v) =>
                                v == null ? 'Select airline' : null,
                            onChanged: (v) =>
                                setState(() => _selectedAirline = v),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        buildInputField(
                          'Departure',
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedDepartureTime,
                            hint: const Text('Choose'),
                            items: departureTimes
                                .map(
                                  (time) => DropdownMenuItem(
                                    value: time,
                                    child: Text(time),
                                  ),
                                )
                                .toList(),
                            validator: (v) =>
                                v == null ? 'Select departure' : null,
                            onChanged: (v) =>
                                setState(() => _selectedDepartureTime = v),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Predict Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : predictPrice,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF081457),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Predict Price',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Prediction Output
                    if (_predictedPrice != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Predicted Price',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '\$${_predictedPrice!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
