import 'package:flutter/material.dart';
import 'package:base_app/src/rust/api/simple.dart';
import 'package:base_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int base = 2;
  int exponent = 3;
  int result = 0;
  String benchmarkResult = '';

  void calculatePowerResult() {
    setState(() {
      result = calculatePower(base: base, exponent: exponent);
    });
  }

  // Thêm biến để lưu kết quả riêng
  String fibResult = '';
  String matrixResult = '';

  // Test Fibonacci riêng
  Future<void> runFibonacciTest() async {
    setState(() {
      fibResult = 'Running Fibonacci test...';
    });

    final stopwatch = Stopwatch()..start();
    final result = calculateFibonacci(n: 35);
    final time = stopwatch.elapsedMilliseconds;

    setState(() {
      fibResult = '''
Fibonacci Test:
n = 35
Result = $result
Time: ${time}ms
''';
    });
  }

  // Test Matrix riêng
  Future<void> runMatrixTest() async {
    setState(() {
      matrixResult = 'Running Matrix test...';
    });

    final stopwatch = Stopwatch()..start();
    final matrix = matrixMultiplication(size: 1000);
    final time = stopwatch.elapsedMilliseconds;

    setState(() {
      matrixResult = '''
Matrix Multiplication Test:
Size: 200x200
Time: ${time}ms
Size of result: ${matrix.length}x${matrix[0].length}
''';
    });
  }

  // Thêm function tính bằng Dart
  List<List<int>> dartMatrixMultiplication(int size) {
    final matrix1 = List.generate(size, (_) => List.filled(size, 1));
    final matrix2 = List.generate(size, (_) => List.filled(size, 2));
    final result = List.generate(size, (_) => List.filled(size, 0));

    for (var i = 0; i < size; i++) {
      for (var j = 0; j < size; j++) {
        for (var k = 0; k < size; k++) {
          result[i][j] += matrix1[i][k] * matrix2[k][j];
        }
      }
    }
    return result;
  }

  // Thêm state để lưu kết quả Dart
  String dartMatrixResult = '';

  // Thêm function test
  Future<void> runDartMatrixTest() async {
    setState(() {
      dartMatrixResult = 'Running Dart Matrix test...';
    });

    final stopwatch = Stopwatch()..start();
    final matrix = dartMatrixMultiplication(1000);
    final time = stopwatch.elapsedMilliseconds;

    setState(() {
      dartMatrixResult = '''
Dart Matrix Multiplication Test:
Size: 500x500
Time: ${time}ms
Size of result: ${matrix.length}x${matrix[0].length}
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rust Performance Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Power Calculator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) => base = int.tryParse(value) ?? 0,
                    decoration: const InputDecoration(labelText: 'Base'),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) => exponent = int.tryParse(value) ?? 0,
                    decoration: const InputDecoration(labelText: 'Exponent'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculatePowerResult,
              child: const Text('Calculate Power'),
            ),
            const SizedBox(height: 20),
            Text(
              'Power Result: $result',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Thay phần benchmark trong build
            const Text(
              'Performance Benchmarks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Trong phần UI, thêm nút test Dart Matrix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: runFibonacciTest,
                  child: const Text('Test Fibonacci'),
                ),
                ElevatedButton(
                  onPressed: runMatrixTest,
                  child: const Text('Test Rust Matrix'),
                ),
                ElevatedButton(
                  onPressed: runDartMatrixTest,
                  child: const Text('Test Dart Matrix'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(fibResult, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 10),
            Text(matrixResult, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 10),
            Text(
              dartMatrixResult,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
