import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hexagon_draw_shape/models/hex_map_data.dart';
import 'package:hexagon_draw_shape/widgets/hexagon_widget.dart';
import 'package:hexagon_draw_shape/widgets/hexagon_scroller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: const HomePage(),
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
  final hexMapData = HexMapData('assets/mapdata.json');
  Map<String, Map<String, String>> mapData = {};
  int maxXIndex = 0;
  int maxYIndex = 0;
  double hexSize = 200;

  @override
  void initState() {
    super.initState();
    hexMapData.fetchMapData().then((onValue) {
      setState(() {
        mapData = onValue;
        maxXIndex = hexMapData.maxX;
        maxYIndex = hexMapData.maxY;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2D Scrolling'),
      ),
      body: (maxXIndex > 0 && maxYIndex > 0)
          ? HexagonGridView(
              hexagonSize: hexSize,
              cacheExtent: 10 * hexSize,
              diagonalDragBehavior: DiagonalDragBehavior.free,
              delegate: TwoDimensionalChildBuilderDelegate(
                maxXIndex: maxXIndex,
                maxYIndex: maxYIndex,
                builder: (BuildContext context, ChildVicinity vicinity) {
                  final key = '${vicinity.xIndex},${vicinity.yIndex}';
                  final hexData = mapData[key];

                  if (hexData != null) {
                    return Hexagon(
                      hexSize: hexSize,
                      terrain: hexData['terrain'] as String,
                      hexArt: hexData['hex_art'] as String,
                    );
                  } else {
                    return Hexagon(
                      hexSize: hexSize,
                      terrain: 'default',
                      hexArt:
                          'assets/images/00063-742592959_hex.png', // Default hex art
                    );
                  }
                },
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
