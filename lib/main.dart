import 'package:flutter/material.dart';
import 'package:hexagon_draw_shape/widgets/hexagon_widget.dart';
import 'package:hexagon_draw_shape/widgets/hexagon_scroller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2D Scrolling'),
      ),
      body: HexagonGridView(
        hexagonSize: 200,
        cacheExtent: 800,
        diagonalDragBehavior: DiagonalDragBehavior.free,
        delegate: TwoDimensionalChildBuilderDelegate(
          maxXIndex: 49,
          maxYIndex: 49,
          builder: (BuildContext context, ChildVicinity vicinity) {
            return const SizedBox(
              width: 200,
              height: 200,
              child: Hexagon(
                imagePath: 'assets/images/00063-742592959_hex.png',
              ),
            );
          },
        ),
      ),
    );
  }
}

class SimpleHexagon extends StatelessWidget {
  const SimpleHexagon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image(image: AssetImage('images/00063-742592959_hex.png')),
          ),
          SizedBox(
            width: 200,
            height: 200,
            child: Hexagon(
              imagePath: 'images/00063-742592959_hex.png',
            ),
          ),
        ],
      ),
    );
  }
}
