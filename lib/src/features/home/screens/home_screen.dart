import 'package:base_app/src/features/home/screens/caro_game_screen.dart';
import 'package:base_app/src/features/media/screen/media_screen.dart';
import 'package:base_app/src/features/performance/screens/performance_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rust Performance Demo')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.bolt, size: 60, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(
                      'Flutter + Rust',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'High Performance Native Apps',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Features Section
              Text(
                'Features',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Performance Test Feature
              _buildFeatureButton(
                icon: Icons.speed,
                label: 'Performance Benchmarks',
                description:
                    'Compare Rust vs Dart performance on complex tasks',
                color: Colors.deepPurple,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PerformanceScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // THÊM MỚI - Game Caro Feature
              _buildFeatureButton(
                icon: Icons.games,
                label: 'Game Caro',
                description: 'Chơi cờ caro với bàn 15x15 ô',
                color: Colors.purple,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CaroGameScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Media Gallery Feature
              _buildFeatureButton(
                icon: Icons.photo_library,
                label: 'Media Gallery',
                description: 'Camera and image gallery with editing features',
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MediaScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Matrix Calculator Feature
              _buildFeatureButton(
                icon: Icons.calculate,
                label: 'Matrix Calculator',
                description: 'Fast matrix operations powered by Rust',
                color: Colors.orange,
                onPressed: () {
                  _showComingSoonDialog('Matrix Calculator');
                },
              ),

              const SizedBox(height: 16),

              // Crypto Operations Feature
              _buildFeatureButton(
                icon: Icons.lock,
                label: 'Crypto Operations',
                description:
                    'Secure cryptographic functions with native performance',
                color: Colors.green,
                onPressed: () {
                  _showComingSoonDialog('Crypto Operations');
                },
              ),

              const SizedBox(height: 16),

              // Image Processing Feature
              _buildFeatureButton(
                icon: Icons.image,
                label: 'Image Processing',
                description:
                    'High-performance image filters and transformations',
                color: Colors.red,
                onPressed: () {
                  _showComingSoonDialog('Image Processing');
                },
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Powered by Flutter Rust Bridge',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$featureName Coming Soon'),
            content: Text(
              'The $featureName feature is under development and will be available in a future update.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
