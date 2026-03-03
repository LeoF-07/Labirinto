import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'ball.dart';
import 'maze.dart';
import 'maze_painter.dart';

class MazePage extends StatefulWidget{
  final int difficulty;
  final double tiltX;
  final double tiltY;
  final double tiltUp;

  const MazePage({super.key, required this.difficulty, required this.tiltX, required this.tiltY, required this.tiltUp});

  @override
  State<MazePage> createState() => MazePageState();
}

class MazePageState extends State<MazePage>{
  late int rows;
  late int cols;

  late StreamSubscription<AccelerometerEvent> accelSub;
  bool falling = true;
  bool started = false;
  bool win = false;

  late double mazeWidth;
  late double mazeHeight;
  late double cellWidth;
  late double cellHeight;
  late Maze maze;
  late Ball ball;

  late double tiltX;
  late double tiltY;
  late double tiltUp;

  @override
  void initState() {
    switch(widget.difficulty){
      case 0:
        rows = 25;
        cols = 25;
        break;
      case 1:
        rows = 33;
        cols = 25;
        break;
      case 2:
        rows = 43;
        cols = 25;
        break;
    }

    mazeWidth = (cols * 16).w;
    mazeHeight = (rows * 16).h;

    cellWidth = mazeWidth / cols;
    cellHeight = mazeHeight / rows;

    maze = Maze(rows, cols);
    ball = Ball(maze.cx * cellWidth + cellWidth / 2, -40);

    tiltX = widget.tiltX / 100;
    tiltY = widget.tiltY / 100;
    tiltUp = widget.tiltUp / 100;

    //_startInitialFall();
    super.initState();
  }

  void restart() {
    try {
      accelSub.cancel();
    } catch (_) {}

    falling = true;
    win = false;
    started = false;

    ball.vx = 0;
    ball.vy = 0;

    ball.x = maze.cx * cellWidth + cellWidth / 2;
    ball.y = -40;

    // Riapro l’ingresso
    maze.walls[0][maze.cx] = false;

    setState(() {});

    _startInitialFall();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Hai vinto! 🎉"),
        content: const Text("Complimenti, sei uscito dal labirinto!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("HomePage"),
          )
        ],
      ),
    );
  }

  void _startInitialFall() {
    started = true;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!falling) {
        timer.cancel();
        return;
      }

      setState(() {
        _updateFall();
        if (!falling && !win) {
          _startTiltControl();
        }
      });
    });
  }

  void _updateFall() {
    // Gravità
    ball.vy += 0.5;

    // Prossima posizione
    double nextY = ball.y + ball.vy;

    // Faccio partire la pallina da una coordinata negativa. Se faccio confronti prima di arrivare al centro della prima cella
    // ottengo errori.
    // !!!!!!!!!!! Anzi, in realtà probabilmente l'unica cosa che succede è che non cade perché sotto ho messo la protezione
    if(ball.y < cellHeight / 2){
      ball.y = nextY;
      return;
    }

    // Calcolo cella sotto la pallina
    int cellX = (ball.x / cellWidth).floor();
    int cellY = ((nextY + ball.radius) / cellHeight).floor();

    // Protezione: se cellY è fuori range, fermiamo la caduta
    /*
    if (cellY < 0 || cellY >= maze.rows) {
      falling = false;
      return;
    }
    */

    if(cellY > rows + 4){
      falling = false;
      Future.microtask((){
        _showWinDialog();
      });
      return;
    }

    // Se sotto c’è un muro → fermiamo la caduta
    if (cellY < rows && maze.walls[cellY][cellX]) {
      falling = false;

      // Allineo la pallina sopra il pavimento
      ball.y = cellY * cellHeight - ball.radius;

      _closeEntrance();
      return;
    }

    // Nessun muro → aggiorno la posizione
    ball.y = nextY;
  }

  void _closeEntrance() {
    maze.walls[0][maze.cx] = true;
  }

  void _startTiltControl() {
    // Attiva accelerometro
    accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (falling || win) {
        accelSub.cancel();
        return;
      }

      double tiltFactorX = tiltX; // sensibilità regolabile
      double tiltFactorY = tiltY;
      double tiltFactorYUp = tiltUp;

      setState(() {
        ball.vx += -event.x * tiltFactorX;
        if (event.y < 0){
          // Salita più veloce
          ball.vy += event.y * tiltFactorYUp;
        }
        else{
          // Discesa normale
          ball.vy += event.y * tiltFactorY;
        }
      });
    });

    // Timer per aggiornare la posizione
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (falling || win) {
        timer.cancel();
        return;
      }

      setState(() {
        _updateBallPhysics();
      });
    });
  }

  void _updateBallPhysics() {
    double nextX = ball.x + ball.vx;
    double nextY = ball.y + ball.vy;

    // Collisione orizzontale
    if (ball.vx > 0) {
      // Sta andando a destra
      int cellX = ((nextX + ball.radius) / cellWidth).floor();
      int cellY = (ball.y / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.x = nextX;
      } else {
        // Collisione a destra
        // Allinea la pallina al bordo sinistro del muro
        ball.x = cellX * cellWidth - ball.radius;
        ball.vx = 0;
      }

    } else if (ball.vx < 0) {
      // Sta andando a sinistra
      int cellX = ((nextX - ball.radius) / cellWidth).floor();
      int cellY = (ball.y / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.x = nextX;
      } else {
        // Collisione a sinistra
        // Allinea la pallina al bordo destro del muro
        ball.x = (cellX + 1) * cellWidth + ball.radius;
        ball.vx = 0;
      }
    }

    // Collisione verticale
    if (ball.vy > 0) {
      // Sta scendendo
      int cellX = (ball.x / cellWidth).floor();
      int cellY = ((nextY + ball.radius) / cellHeight).floor();

      if(cellY > rows - 1){
        accelSub.cancel();
        falling = true;
        win = true;
        _startInitialFall();
        return;
      }
      else if (!maze.walls[cellY][cellX]) {
        ball.y = nextY;
      } else {
        // Collisione con il pavimento
        // Allineo la pallina sopra il pavimento
        ball.y = cellY * cellHeight - ball.radius;
        ball.vy = 0;
      }

    } else if (ball.vy < 0) {
      // Sta salendo
      int cellX = (ball.x / cellWidth).floor();
      int cellY = ((nextY - ball.radius) / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.y = nextY;
      } else {
        // Collisione con il soffitto
        // Allineo la pallina sotto il soffitto
        ball.y = (cellY + 1) * cellHeight + ball.radius;
        ball.vy = 0;
      }
    }

    // Attrito (la velocità della pallina non può crescere all'infinito)
    ball.vx *= 0.95;
    ball.vy *= 0.95;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 40.h,
                left: 20.w,
                child: IconButton(onPressed: () {win = true; Navigator.pop(context);}, icon: Icon(Icons.arrow_back_rounded, size: 40.w)),
              ),
              GestureDetector(
                onDoubleTap: !started ? _startInitialFall : restart,
                child: Center(
                  child: CustomPaint(
                    painter: MazePainter(maze, ball),
                    size: Size(mazeWidth, mazeHeight)
                  )
                )
              )
            ],
          ),
        ),
      )
    );
  }
}