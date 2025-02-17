import 'package:flutter/material.dart';
import 'package:flutter_animated_grid/flutter_animated_grid.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Grid Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Changed this line
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GridAnimatedDemo()),
            );
          },
          child: const Text('Show Animated Grid'),
        ),
      ),
    );
  }
}

class GridAnimatedDemo extends StatelessWidget {
  const GridAnimatedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Grid Example'),
        leading: IconButton( // Added back button explicitly
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedGridView(
        crossAxisCount: 2,
        spacing: 15,
        staggerDuration: const Duration(milliseconds: 150),
        animationDuration: const Duration(milliseconds: 700),
        initialSlideOffset: 70.0,
        placeholderColor: Colors.grey[300],
        imageFit: BoxFit.fitWidth,
        borderRadius: 20.0,
        shadowColor: Colors.purple,
        shadowBlurRadius: 20.0,
        shadowOffset: const Offset(2, 5),
        children: [
          Image.network(
        'https://picsum.photos/1200/1600?random=1',
        fit: BoxFit.cover,
          ),
          Image.network(
        'https://picsum.photos/1200/1600?random=2',
        fit: BoxFit.cover,
          ),
          Image.network(
        'https://picsum.photos/1200/1600?random=3',
        fit: BoxFit.cover,
          ),
          Image.network(
        'https://picsum.photos/1200/1600?random=4',
        fit: BoxFit.cover,
          ),
          Container(
        color: Colors.red,
        child: const Center(child: Text('Custom Widget')),
          ),
          Container(
        color: Colors.green,
        child: const Center(child: Text('Another Custom Widget')),
          ),
          const Icon(Icons.star, size: 50),
        ],
      ),
    );
  }
}
