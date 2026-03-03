import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'ball.dart';
import 'maze.dart';
import 'maze_painter.dart';

// Classe MazePage, implementa tutta la logica del labirinto e mostra il gioco a schermo
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
  late Timer cronometro;
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

  String seconds = "00";
  String minutes = "00";

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

    super.initState();
  }

  void restart() {
    try {
      accelSub.cancel();
      cronometro.cancel();
    } catch (_) {}

    seconds = "00";
    minutes = "00";

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

  void _showConfirmDialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Abbandona"),
        content: Text("Sei sicuro di voler abbandonare la partita?"),
        actions: [
          TextButton(
            onPressed: () {
              win = true;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Abbandona"),
          )
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Hai vinto! 🎉"),
        content: Text("Complimenti, sei uscito dal labirinto in${int.parse(minutes) > 0 ? " ${minutes}m e" : ""} ${seconds}s"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("Home Page"),
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
          cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
            if(win){
              timer.cancel();
            }

            int s = int.parse(seconds);
            int m = int.parse(minutes);

            s++;
            if(s == 60){
              m++;
              s = 0;
            }

            seconds = (s < 10) ? "0$s" : "$s";
            minutes = (m < 10) ? "0$m" : "$m";
          });
          _startTiltControl();
        }
      });
    });
  }

  void _updateFall() {
    // Gravità
    ball.vy += 0.2;

    // Prossima posizione
    double nextY = ball.y + ball.vy;

    // Faccio partire la pallina da una coordinata negativa. Se faccio confronti prima di arrivare al centro della prima cella
    // ottengo errori.
    if(ball.y < cellHeight / 2){
      ball.y = nextY;
      return;
    }

    // Calcolo cella sotto la pallina
    int cellX = (ball.x / cellWidth).floor();
    int cellY = ((nextY + ball.radius) / cellHeight).floor();

    if(cellY > rows + 2){
      falling = false;
      Future.microtask((){
        _showWinDialog();
      });
      return;
    }

    // Quando incontra il pavimento ferma la caduta
    if (cellY < rows && maze.walls[cellY][cellX]) {
      falling = false;

      // Allinea la pallina sopra il pavimento
      ball.y = cellY * cellHeight - ball.radius;

      _closeEntrance();
      return;
    }

    ball.y = nextY;
  }

  void _closeEntrance() {
    maze.walls[0][maze.cx] = true;
  }

  void _startTiltControl() {
    // Attivo accelerometro
    accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (falling || win) {
        accelSub.cancel();
        return;
      }

      setState(() {
        ball.vx += -event.x * tiltX;
        if (event.y < 0){
          // Salita più veloce
          ball.vy += event.y * tiltUp;
        }
        else{
          // Discesa normale
          ball.vy += event.y * tiltY;
        }
      });
    });

    // Timer per aggiornare la posizione
    Timer.periodic(Duration(milliseconds: 16), (timer) {
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
        backgroundColor: Color.lerp(Colors.orangeAccent, Colors.white, 0.6)!,
        body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 40.h,
                left: 20.w,
                child: IconButton(onPressed: _showConfirmDialog, icon: Icon(Icons.arrow_back_rounded, size: 40.w)),
              ),
              Positioned(
                top: 50.h,
                right: 30.w,
                child: Text("$minutes:$seconds", style: TextStyle(fontSize: 30.w)),
              ),
              GestureDetector(
                onDoubleTap: !started ? _startInitialFall : restart,
                child: Center(
                  child: CustomPaint(
                    painter: MazePainter(maze, ball),
                    size: Size(mazeWidth, mazeHeight)
                  )
                )
              ),
              Positioned(
                left: 5.w,
                bottom: widget.difficulty == 2 ? 20.h : 90.h,
                child: Align(
                  alignment: Alignment.center,
                  child: Text("Double Tap per iniziare / ricominciare", style: TextStyle(fontSize: 18.w)),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}