import 'package:flutter/material.dart';
import 'constants.dart';
import 'tile.dart';
import 'dart:ui';
import 'custom_paint.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      home: Home2048(),
    );
  }
}

class Home2048 extends StatefulWidget {
  @override
  _Home2048State createState() => _Home2048State();
}

class _Home2048State extends State<Home2048>
    with SingleTickerProviderStateMixin {
  Timer _timer;
  int counter = 10;
  AnimationController controller;
  List<List<Tile>> grid =
      List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
  List<Tile> toAdd = [];
  Iterable<Tile> get flattenedGrid => grid.expand((e) => e);
  Iterable<List<Tile>> get cols =>
      List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  bool gameMode = false;

  @override
  void initState() {
    super.initState();
    // timerSimulator =
    //     AnimationController(vsync: this, duration: Duration(seconds: 5));
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          toAdd.forEach((element) {
            grid[element.y][element.x].val = element.val;
          });
          flattenedGrid.forEach((element) => element.resetAnimations());
          toAdd.clear();
        });
      }
    });

    restartGame();
    decreasingProgressBar();
  }

  void addNewTile(List<int> newTiles) {
    List<Tile> empty = flattenedGrid.where((e) => e.val == 0).toList();
    empty.shuffle();
    for (int i = 0; i < newTiles.length; i++) {
      toAdd.add(Tile(empty[i].x, empty[i].y, newTiles[i])..appear(controller));
    }
  }

  void decreasingProgressBar() {
    counter = 10;

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
        } else {
          _timer.cancel();
          restartGame();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = MediaQuery.of(context).size.width - 16.0 * 2;
    double tileSize = (gridSize - 4.0 * 2) / 4;
    List<Widget> stackItems = [];
    stackItems.addAll(
      flattenedGrid.map(
        (e) => Positioned(
          left: e.x * tileSize,
          top: e.y * tileSize,
          width: tileSize,
          height: tileSize,
          child: Center(
            child: Container(
              width: tileSize - 4.0 * 2,
              height: tileSize - 4.0 * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: lightBrown,
              ),
            ),
          ),
        ),
      ),
    );

    stackItems.addAll(
      [flattenedGrid, toAdd].expand((tile) => tile).map(
            (tile) => AnimatedBuilder(
              animation: controller,
              builder: (context, child) => tile.animatedValue.value == 0
                  ? SizedBox()
                  : Positioned(
                      left: tile.animatedX.value * tileSize,
                      top: tile.animatedY.value * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Center(
                        child: Container(
                          width: (tileSize - 4.0 * 2) * tile.scale.value,
                          height: (tileSize - 4.0 * 2) * tile.scale.value,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: gameMode == false
                                  ? numTileColor[tile.animatedValue.value]
                                  : tan),
                          child: Center(
                            child: gameMode == false
                                ? Text(
                                    '${tile.animatedValue.value}',
                                    style: TextStyle(
                                      color: tile.animatedValue.value <= 4
                                          ? greyText
                                          : Colors.white,
                                      fontSize: 35,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Image.asset(
                                      'assets/question.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
    );

    return Scaffold(
      backgroundColor: tan,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: <Widget>[
                RaisedButton(
                  color: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "Visibility",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: changeMode,
                )
              ],
            ),
            Container(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy < -250 &&
                      canSwipeUp()) {
                    doSwipe(swipeUp);
                  } else if (details.velocity.pixelsPerSecond.dy > 250 &&
                      canSwipeDown()) {
                    doSwipe(swipeDown);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx < -1000 &&
                      canSwipeLeft()) {
                    doSwipe(swipeLeft);
                  } else if (details.velocity.pixelsPerSecond.dx > 1000 &&
                      canSwipeRight()) {
                    doSwipe(swipeRight);
                  }
                },
                child: Stack(
                  children: stackItems,
                ),
              ),
              width: gridSize,
              height: gridSize,
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: darkBrown,
              ),
            ),
            Container(
              width: 400,
              child: CustomPaint(
                size: Size(10, 10),
                painter: MyPainter(paintCounter: counter),
              ),
            ),
            Container(
              height: 80,
              width: 400,
              child: RaisedButton(
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Restart",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                onPressed: restartGame,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFn) {
    setState(() {
      swipeFn();
      addNewTile([2]);
      controller.forward(from: 0);
    });
  }

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.map((e) => e.reversed.toList()).any(canSwipe);
  bool canSwipeUp() => cols.any(canSwipe);
  bool canSwipeDown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i].val == 0) {
        if (tiles.skip(i + 1).any((e) => e.val != 0)) {
          return true;
        }
      } else {
        Tile nextNonZero =
            tiles.skip(i + 1).firstWhere((e) => e.val != 0, orElse: () => null);
        if (nextNonZero != null && nextNonZero.val == tiles[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void swipeLeft() => grid.forEach(mergeTiles);
  void swipeRight() => grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
  void swipeUp() => cols.forEach(mergeTiles);
  void swipeDown() => cols.map((e) => e.reversed.toList()).forEach(mergeTiles);

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Iterable<Tile> toCheck =
          tiles.skip(i).skipWhile((value) => value.val == 0);
      if (toCheck.isNotEmpty) {
        Tile t = toCheck.first;
        Tile merge =
            toCheck.skip(1).firstWhere((t) => t.val != 0, orElse: () => null);
        if (merge != null && merge.val != t.val) {
          merge = null;
        }
        if (tiles[i] != t || merge != null) {
          int resultValue = t.val;
          t.moveTo(controller, tiles[i].x, tiles[i].y);
          if (merge != null) {
            resultValue += merge.val;
            merge.moveTo(controller, tiles[i].x, tiles[i].y);
            merge.bounce(controller);
            merge.changeNumber(controller, resultValue);
            merge.val = 0;
            t.changeNumber(controller, 0);
          }
          t.val = 0;
          tiles[i].val = resultValue;
        }
      }
    }
  }

  void restartGame() {
    setState(() {
      flattenedGrid.forEach((e) {
        e.val = 0;
        e.resetAnimations();
      });
      toAdd.clear();
      addNewTile([2, 2]);
      controller.forward(from: 0);
      decreasingProgressBar();
      MyPainter(paintCounter: counter);
    });
  }

  void changeMode() {
    setState(() {
      gameMode == false ? gameMode = true : gameMode = false;
    });
  }
}