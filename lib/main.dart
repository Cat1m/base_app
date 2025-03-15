import 'package:base_app/src/features/media/screen/media_screen.dart';
import 'package:flutter/material.dart';
import 'package:base_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rust Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Existing state variables...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rust Performance Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MediaScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Existing body content...
      ),
    );
  }
}
