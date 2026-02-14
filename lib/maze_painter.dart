import 'package:flutter/material.dart';
import 'ball.dart';
import 'maze.dart';

class MazePainter extends CustomPainter {
  Maze maze;
  Ball ball;

  MazePainter(this.maze, this.ball);

  @override
  void paint(Canvas canvas, Size size) {
    int rows = maze.rows;
    int cols = maze.cols;

    double cellWidth = size.width / cols;
    double cellHeight = size.height / rows;

    Paint wallPaint = Paint()..color = Colors.black; // = wallPaint.color = Colors.black;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (maze.walls[r][c]) {
          Rect rect = Rect.fromLTWH(
            c * cellWidth,
            r * cellHeight,
            cellWidth,
            cellHeight,
          );

          canvas.drawRect(rect, wallPaint);
        }
      }
    }

    // Pallina
    canvas.drawCircle(
      Offset(ball.x, ball.y),
      ball.radius,
      Paint()..color = Colors.red
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}