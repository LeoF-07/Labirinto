import 'package:flutter/material.dart';

enum Direction { right, left }

class SwipeSelector extends StatefulWidget {
  const SwipeSelector({super.key});

  @override
  State<SwipeSelector> createState() => SwipeSelectorState();
}

class SwipeSelectorState extends State<SwipeSelector> {
  int index = 0;
  Direction direction = Direction.left;

  final List<String> items = ["Uno", "Due", "Tre", "Quattro"];

  String? outgoing;
  String? incoming;

  double outgoingX = 0;
  double incomingX = 0;

  void animateTo(int newIndex, Direction dir) {
    outgoing = items[index];
    incoming = items[newIndex];
    direction = dir;

    // posizioni iniziali
    outgoingX = 0;
    incomingX = dir == Direction.left ? 200 : -200;

    setState(() {});

    // frame successivo → animazione
    Future.delayed(const Duration(milliseconds: 16), () {
      setState(() {
        outgoingX = dir == Direction.left ? -200 : 200;
        incomingX = 0;
      });
    });

    // fine animazione → pulizia
    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        index = newIndex;
        outgoing = null;
        incoming = null;
      });
    });
  }

  void selectNext() {
    animateTo((index + 1) % items.length, Direction.left);
  }

  void selectPrevious() {
    animateTo((index - 1 + items.length) % items.length, Direction.right);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity;
        if (v == null) return;

        if (v < 0) selectNext();
        if (v > 0) selectPrevious();
      },
      child: Center(
        child: SizedBox(
          width: 200,
          height: 60,
          child: Stack(
            children: [
              // Mostra il testo statico SOLO quando non c’è animazione
              if (outgoing == null && incoming == null)
                _buildText(items[index]),

              if (outgoing != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  left: outgoingX,
                  top: 0,
                  child: _buildText(outgoing!),
                ),

              if (incoming != null)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  left: incomingX,
                  top: 0,
                  child: _buildText(incoming!),
                ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return SizedBox(
      width: 200,
      height: 60,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}





/*
import 'package:flutter/material.dart';

enum Direction {right, left}

class SwipeSelector extends StatefulWidget {
  const SwipeSelector({super.key});

  @override
  State<SwipeSelector> createState() => SwipeSelectorState();
}

class SwipeSelectorState extends State<SwipeSelector>{
  int index = 0;
  Direction direction = Direction.left;
  final List items = ["Uno", "Due", "Tre", "Quattro"];

  void selectNext(){
    setState(() {
      index = (index + 1) % items.length;
      direction = Direction.left;
    });
  }

  void selectPrevious(){
    setState(() {
      index = (index - 1 + items.length) % items.length;
      direction = Direction.right;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          selectNext();
        }
        else if (details.primaryVelocity! > 0) {
          selectPrevious();
        }
      },
      child: Center(
          child: SizedBox(
            width: double.infinity,
            child:
          )
      ),
    );
  }
}
*/

/*
class SwipeSelectorState extends State<SwipeSelector>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int? outgoingIndex;
  bool isAnimating = false;
  Direction direction = Direction.left;

  late final AnimationController _controller;
  late Animation<Offset> _inAnimation;
  late Animation<Offset> _outAnimation;

  final items = ["Uno", "Due", "Tre", "Quattro"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          outgoingIndex = null;
          isAnimating = false;
        });
        _controller.reset();
      }
    });
  }

  void _setAnimations() {
    final inBegin =
    direction == Direction.left ? const Offset(1, 0) : const Offset(-1, 0);
    final outEnd =
    direction == Direction.left ? const Offset(-2, 0) : const Offset(2, 0);

    _inAnimation = Tween<Offset>(
      begin: inBegin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _outAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: outEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _navigate(Direction dir, int nextIndex) {
    if (isAnimating) return;
    setState(() {
      direction = dir;
      outgoingIndex = currentIndex;
      currentIndex = nextIndex;
      isAnimating = true;
    });
    _setAnimations();
    _controller.forward();
  }

  void selectNext() =>
      _navigate(Direction.left, (currentIndex + 1) % items.length);

  void selectPrevious() => _navigate(
      Direction.right, (currentIndex - 1 + items.length) % items.length);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildItem(String text) {
    return Text(text, style: const TextStyle(fontSize: 40));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) selectNext();
        else if (details.primaryVelocity! > 0) selectPrevious();
      },
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isAnimating) ...[
                  // Uscente
                  SlideTransition(
                    position: _outAnimation,
                    child: _buildItem(items[outgoingIndex!]),
                  ),
                  // Entrante
                  SlideTransition(
                    position: _inAnimation,
                    child: _buildItem(items[currentIndex]),
                  ),
                ] else
                // Nessuna animazione: mostro solo quello corrente, fermo
                  _buildItem(items[currentIndex]),
              ],
            ),
          ),
        )
      ),
    );
  }
}
*/
