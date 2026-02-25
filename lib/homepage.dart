import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:labirinto/maze_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Offset> offsets = [
    Offset(200.h, 100.w),
    Offset(230.h, 100.w),
    Offset(260.h, 100.w),
    Offset(260.h, 130.w),
    Offset(260.h, 160.w),
    Offset(230.h, 160.w),
    Offset(200.h, 160.w),
    Offset(200.h, 190.w),
    Offset(200.h, 220.w)
  ];
  
  final List charsOfTitle = "LABIRINTO".split("");

  Stack creaStackTitolo(){
    List<Positioned> children = [];

    for(int i = 0; i < charsOfTitle.length; i++){
      children.add(
        Positioned(
          top: offsets[i].dx,
          left: offsets[i].dy,
          child: Text(charsOfTitle[i], style: TextStyle(fontSize: 20.w)),
        )
      );
    }

    Stack stack = Stack(
      children: children,
    );
    return stack;
  }

  void startGame(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => MazePage()));
  }

  @override
  Widget build(BuildContext context) {
    Stack titolo = creaStackTitolo();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 300.h,
              child: titolo,
            ),
            ElevatedButton(
              onPressed: startGame,
              child: Text("Inizia Partita"),
            )
          ],
        )
      ),
    );
  }
}