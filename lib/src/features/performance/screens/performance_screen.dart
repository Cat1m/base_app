import 'dart:math';

import 'package:flutter/material.dart';
import 'package:base_app/src/rust/api/simple.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arrayLengthController = TextEditingController(text: '10000');
  final _matrixSizeController = TextEditingController(text: '100');
  final _fibNumberController = TextEditingController(text: '45');

  // Performance results
  double _sortArrayTimeRust = 0;
  double _sortArrayTimeDart = 0;
  double _matrixMultTimeRust = 0;
  double _matrixMultTimeDart = 0;
  double _fibonacciTimeRust = 0;
  double _fibonacciTimeDart = 0;

  bool _isLoading = false;
  String _currentOperation = '';

  @override
  void dispose() {
    _arrayLengthController.dispose();
    _matrixSizeController.dispose();
    _fibNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rust Performance Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Test the performance of Rust vs. Dart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Parameters Section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Parameters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Array sorting size
                        TextFormField(
                          controller: _arrayLengthController,
                          decoration: const InputDecoration(
                            labelText: 'Array Length',
                            border: OutlineInputBorder(),
                            helperText: 'Length of random array to sort',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Matrix size
                        TextFormField(
                          controller: _matrixSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Matrix Size',
                            border: OutlineInputBorder(),
                            helperText:
                                'Size of matrix for multiplication test',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Fibonacci number
                        TextFormField(
                          controller: _fibNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Fibonacci Number',
                            border: OutlineInputBorder(),
                            helperText: 'Calculate nth Fibonacci number',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Run Tests Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _runAllTests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(_isLoading ? 'Running...' : 'Run All Tests'),
                ),

                const SizedBox(height: 16),

                // Individual Test Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _runSortingTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Run Sort Test'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _runMatrixTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Run Matrix Test'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _runFibonacciTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Run Fibonacci'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Results Section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sorting Results
                        _buildResultItem(
                          label: 'Array Sorting',
                          rustTime: _sortArrayTimeRust,
                          dartTime: _sortArrayTimeDart,
                          color: Colors.blue,
                        ),

                        const Divider(),

                        // Matrix Multiplication Results
                        _buildResultItem(
                          label: 'Matrix Multiplication',
                          rustTime: _matrixMultTimeRust,
                          dartTime: _matrixMultTimeDart,
                          color: Colors.orange,
                        ),

                        const Divider(),

                        // Fibonacci Results
                        _buildResultItem(
                          label: 'Fibonacci',
                          rustTime: _fibonacciTimeRust,
                          dartTime: _fibonacciTimeDart,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 16),

                        // Performance Summary
                        if (_hasAnyResult())
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Performance Summary',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getPerformanceSummary(),
                                  style: const TextStyle(height: 1.5),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentOperation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem({
    required String label,
    required double rustTime,
    required double dartTime,
    required Color color,
  }) {
    // If we have no results yet, show placeholder
    if (rustTime == 0 && dartTime == 0) {
      return ListTile(
        title: Text(label),
        subtitle: const Text('No results yet'),
        leading: Icon(Icons.timer_outlined, color: color),
      );
    }

    // Calculate performance difference as a multiplier
    final double speedup = dartTime > 0 ? dartTime / rustTime : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(label),
            subtitle: Text('Rust is ${speedup.toStringAsFixed(1)}x faster'),
            leading: Icon(Icons.speed, color: color),
          ),
          const SizedBox(height: 8),
          // Progress indicator showing relative performance
          LinearProgressIndicator(
            value: _calculateRelativePerformance(rustTime, dartTime),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 8),
          // Time measurements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeDisplay('Rust', rustTime, Colors.deepPurple),
              _buildTimeDisplay('Dart', dartTime, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String label, double timeMs, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: ${timeMs.toStringAsFixed(2)} ms'),
      ],
    );
  }

  // Calculate relative performance for progress indicator
  double _calculateRelativePerformance(double rustTime, double dartTime) {
    if (rustTime <= 0 || dartTime <= 0) return 0;
    // The faster option will have a smaller time value
    if (rustTime < dartTime) {
      // Rust is faster, we want to show rustTime as short portion of the bar
      return rustTime / dartTime; // Will be less than 1.0
    } else {
      // Dart is faster
      return dartTime / rustTime; // Will be less than 1.0
    }
  }

  // Check if we have any results to display
  bool _hasAnyResult() {
    return _sortArrayTimeRust > 0 ||
        _matrixMultTimeRust > 0 ||
        _fibonacciTimeRust > 0;
  }

  // Get a performance summary message
  String _getPerformanceSummary() {
    if (!_hasAnyResult()) return 'Run tests to see performance comparison';

    final List<String> results = [];

    if (_sortArrayTimeRust > 0 && _sortArrayTimeDart > 0) {
      final speedup = _sortArrayTimeDart / _sortArrayTimeRust;
      results.add(
        'Array sorting: Rust is ${speedup.toStringAsFixed(1)}x faster',
      );
    }

    if (_matrixMultTimeRust > 0 && _matrixMultTimeDart > 0) {
      final speedup = _matrixMultTimeDart / _matrixMultTimeRust;
      results.add(
        'Matrix multiplication: Rust is ${speedup.toStringAsFixed(1)}x faster',
      );
    }

    if (_fibonacciTimeRust > 0 && _fibonacciTimeDart > 0) {
      final speedup = _fibonacciTimeDart / _fibonacciTimeRust;
      results.add('Fibonacci: Rust is ${speedup.toStringAsFixed(1)}x faster');
    }

    final overallSpeedup = _calculateOverallSpeedup();
    results.add(
      'Overall: Rust is ${overallSpeedup.toStringAsFixed(1)}x faster than Dart',
    );

    return results.join('\n');
  }

  double _calculateOverallSpeedup() {
    double totalRustTime = 0;
    double totalDartTime = 0;

    if (_sortArrayTimeRust > 0 && _sortArrayTimeDart > 0) {
      totalRustTime += _sortArrayTimeRust;
      totalDartTime += _sortArrayTimeDart;
    }

    if (_matrixMultTimeRust > 0 && _matrixMultTimeDart > 0) {
      totalRustTime += _matrixMultTimeRust;
      totalDartTime += _matrixMultTimeDart;
    }

    if (_fibonacciTimeRust > 0 && _fibonacciTimeDart > 0) {
      totalRustTime += _fibonacciTimeRust;
      totalDartTime += _fibonacciTimeDart;
    }

    if (totalRustTime == 0) return 0;
    return totalDartTime / totalRustTime;
  }

  Future<void> _runAllTests() async {
    if (_formKey.currentState!.validate()) {
      await _runSortingTest();
      await _runMatrixTest();
      await _runFibonacciTest();
    }
  }

  Future<void> _runSortingTest() async {
    if (!_formKey.currentState!.validate()) return;

    final int arrayLength = int.parse(_arrayLengthController.text);

    setState(() {
      _isLoading = true;
      _currentOperation = 'Running sorting test...';
    });

    try {
      // Rust implementation
      final rustStart = DateTime.now();
      final sortedArray = sortLargeArray(size: arrayLength);
      final rustEnd = DateTime.now();
      final rustDuration =
          rustEnd.difference(rustStart).inMicroseconds / 1000.0;

      // Dart implementation
      final dartStart = DateTime.now();
      final dartArray = List.generate(
        arrayLength,
        (_) => Random().nextInt(1000000),
      );
      dartArray.sort();
      final dartEnd = DateTime.now();
      final dartDuration =
          dartEnd.difference(dartStart).inMicroseconds / 1000.0;

      setState(() {
        _sortArrayTimeRust = rustDuration;
        _sortArrayTimeDart = dartDuration;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to run sorting test: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _runMatrixTest() async {
    if (!_formKey.currentState!.validate()) return;

    final int matrixSize = int.parse(_matrixSizeController.text);

    setState(() {
      _isLoading = true;
      _currentOperation = 'Running matrix multiplication test...';
    });

    try {
      // Rust implementation
      final rustStart = DateTime.now();
      final rustResult = matrixMultiplication(size: matrixSize);
      final rustEnd = DateTime.now();
      final rustDuration =
          rustEnd.difference(rustStart).inMicroseconds / 1000.0;

      // Dart implementation
      final dartStart = DateTime.now();

      // Create matrices
      final matrix1 = List.generate(
        matrixSize,
        (_) => List.filled(matrixSize, 1),
      );
      final matrix2 = List.generate(
        matrixSize,
        (_) => List.filled(matrixSize, 2),
      );

      // Perform matrix multiplication
      final result = List.generate(
        matrixSize,
        (i) => List.filled(matrixSize, 0),
      );

      for (int i = 0; i < matrixSize; i++) {
        for (int k = 0; k < matrixSize; k++) {
          for (int j = 0; j < matrixSize; j++) {
            result[i][j] += matrix1[i][k] * matrix2[k][j];
          }
        }
      }

      final dartEnd = DateTime.now();
      final dartDuration =
          dartEnd.difference(dartStart).inMicroseconds / 1000.0;

      setState(() {
        _matrixMultTimeRust = rustDuration;
        _matrixMultTimeDart = dartDuration;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to run matrix test: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _runFibonacciTest() async {
    if (!_formKey.currentState!.validate()) return;

    final int n = int.parse(_fibNumberController.text);

    setState(() {
      _isLoading = true;
      _currentOperation = 'Computing Fibonacci($n)...';
    });

    try {
      // Rust implementation
      final rustStart = DateTime.now();
      final rustResult = calculateFibonacci(n: n);
      final rustEnd = DateTime.now();
      final rustDuration =
          rustEnd.difference(rustStart).inMicroseconds / 1000.0;

      // Dart implementation
      final dartStart = DateTime.now();

      int a = 0;
      int b = 1;
      for (int i = 2; i <= n; i++) {
        final temp = a + b;
        a = b;
        b = temp;
      }

      final dartEnd = DateTime.now();
      final dartDuration =
          dartEnd.difference(dartStart).inMicroseconds / 1000.0;

      setState(() {
        _fibonacciTimeRust = rustDuration;
        _fibonacciTimeDart = dartDuration;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to run Fibonacci test: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }
}
