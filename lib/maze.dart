import 'dart:math';

// Classe Maze, implementa il labirinto e la logica di generazione
class Maze {
  int rows;
  int cols;
  late List<List<bool>> walls;
  late int cx;

  // Direzioni possibili: su, giù, sinistra, destra
  final List<Point> directions = [
    Point(0, -1),
    Point(0, 1),
    Point(-1, 0),
    Point(1, 0),
  ];

  late Random rand;

  Maze(this.rows, this.cols){
    walls = List.generate(rows, (_) => List.generate(cols, (_) => true));
    _generate(1, 1); // Punto di partenza
    cx = _centerColumn();
    _addEntrances();
  }

  void _generate(int x, int y) {
    rand = Random(); // Posso passare un seed al random per generare lo stesso labirinto ogni volta
    carve(1, 1);
  }

  // Funzione ricorsiva DFS
  void carve(int x, int y){
    walls[y][x] = false; // libera la cella

    // Mischia le direzioni per ottenere un labirinto diverso ogni volta
    directions.shuffle(rand);

    for (Point dir in directions) {
      int nx = (x + dir.x * 2).toInt();
      int ny = (y + dir.y * 2).toInt();

      // Controlla che la cella sia dentro la griglia
      if (ny > 0 && ny < rows - 1 && nx > 0 && nx < cols - 1) {
        if (walls[ny][nx] == true) {
          // Scava la cella intermedia
          walls[y + dir.y.toInt()][x + dir.x.toInt()] = false;
          carve(nx, ny);
        }
      }
    }
  }

  int _centerColumn() {
    int center = cols ~/ 2; // = (cols / 2).floor()
    if (center.isEven) {
      center--; // Porto il centro alla dispari più vicina
    }
    return center;
  }

  void _addEntrances() {
    walls[0][cx] = false; // buco nel bordo
    walls[1][cx] = false; // cella interna sotto l’entrata

    // Uscita in basso
    walls[rows - 1][cx + 2] = false; // buco nel bordo
    walls[rows - 2][cx + 2] = false; // cella interna sopra l’uscita
  }

}