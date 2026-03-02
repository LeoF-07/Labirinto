import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'ball.dart';
import 'maze.dart';
import 'maze_painter.dart';

class MazePage extends StatefulWidget{
  final int difficulty;

  const MazePage({super.key, required this.difficulty});

  @override
  State<MazePage> createState() => MazePageState();
}

class MazePageState extends State<MazePage>{
  late int rows;
  late int cols;

  late StreamSubscription<AccelerometerEvent> accelSub;
  bool falling = true;

  late double mazeWidth;
  late double mazeHeight;
  late double cellWidth;
  late double cellHeight;
  late Maze maze;
  late Ball ball;

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

    _startInitialFall();
    super.initState();
  }

  void _startInitialFall() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!falling) {
        timer.cancel();
        return;
      }

      setState(() {
        _updateFall();
        if (!falling) {
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
    if (cellY < 0 || cellY >= maze.rows) {
      falling = false;
      return;
    }

    // Se sotto c’è un muro → fermiamo la caduta
    if (maze.walls[cellY][cellX]) {
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
      if (falling) return;

      /*const double tiltFactorX = 0.12; // sensibilità regolabile
      const double tiltFactorY = 0.12;
      const tiltFactorYUp = 0.22;*/

      const double tiltFactorX = 0.09; // sensibilità regolabile
      const double tiltFactorY = 0.09;
      const tiltFactorYUp = 0.10;

      setState(() {
        // Movimento orizzontale
        //ball.vx += -event.x * tiltFactor;
        ball.vx += -event.x * tiltFactorX;

        // Movimento verticale
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

    // Timer fisico per aggiornare la posizione
    Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (falling) return;

      setState(() {
        _updateBallPhysics();
      });
    });
  }

  /*
  void _updateBallPhysics() {
    double nextX = ball.x + ball.vx;
    double nextY = ball.y + ball.vy;

    // Collisione orizzontale
    int cellX = ((nextX + ball.radius) / cellWidth).floor();
    int cellY = (ball.y / cellHeight).floor();

    if (!maze.walls[cellY][cellX]) {
      ball.x = nextX;
    } else {
      ball.vx = 0;
    }

    // Collisione verticale
    cellX = (ball.x / cellWidth).floor();
    cellY = ((nextY + ball.radius) / cellHeight).floor();


    if (!maze.walls[cellY][cellX]) {
      ball.y = nextY;
    } else {
      ball.vy = 0;
    }

    // Attrito leggero
    ball.vx *= 0.95;
    ball.vy *= 0.95;
  }
  */

  void _updateBallPhysics() {
    double nextX = ball.x + ball.vx;
    double nextY = ball.y + ball.vy;

    // -------------------------
    // COLLISIONE ORIZZONTALE
    // -------------------------

    if (ball.vx > 0) {
      // Sta andando a destra → controllo il bordo destro
      int cellX = ((nextX + ball.radius) / cellWidth).floor();
      int cellY = (ball.y / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.x = nextX;
      } else {
        // Allineo la pallina al bordo sinistro del muro
        ball.x = cellX * cellWidth - ball.radius;
        ball.vx = 0;
      }

    } else if (ball.vx < 0) {
      // Sta andando a sinistra → controllo il bordo sinistro
      int cellX = ((nextX - ball.radius) / cellWidth).floor();
      int cellY = (ball.y / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.x = nextX;
      } else {
        // Allineo la pallina al bordo destro del muro
        ball.x = (cellX + 1) * cellWidth + ball.radius;
        ball.vx = 0;
      }
    }

    // -------------------------
    // COLLISIONE VERTICALE
    // -------------------------

    if (ball.vy > 0) {
      // Sta scendendo → controllo il bordo inferiore
      int cellX = (ball.x / cellWidth).floor();
      int cellY = ((nextY + ball.radius) / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.y = nextY;
      } else {
        // Allineo la pallina sopra il pavimento
        ball.y = cellY * cellHeight - ball.radius;
        ball.vy = 0;
      }

    } else if (ball.vy < 0) {
      // Sta salendo → controllo il bordo superiore
      int cellX = (ball.x / cellWidth).floor();
      int cellY = ((nextY - ball.radius) / cellHeight).floor();

      if (!maze.walls[cellY][cellX]) {
        ball.y = nextY;
      } else {
        // Allineo la pallina sotto il soffitto
        ball.y = (cellY + 1) * cellHeight + ball.radius;
        ball.vy = 0;
      }
    }

    // -------------------------
    // ATTRITO
    // -------------------------
    ball.vx *= 0.95;
    ball.vy *= 0.95;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: CustomPaint(
              painter: MazePainter(maze, ball),
              size: Size(mazeWidth, mazeHeight)
            )
          )
      ),
    );
  }
}