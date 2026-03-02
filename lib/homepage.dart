import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:labirinto/maze_page.dart';
import 'package:labirinto/swipe_selector.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<SwipeSelectorState> selectorKey = GlobalKey();

  final List<Offset> offsets = [
    Offset(100.h, 120.w),
    Offset(130.h, 120.w),
    Offset(160.h, 120.w),
    Offset(160.h, 150.w),
    Offset(160.h, 180.w),
    Offset(130.h, 180.w),
    Offset(100.h, 180.w),
    Offset(100.h, 210.w),
    Offset(100.h, 240.w)
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
    
    children.add(
      Positioned(
        top: 140.h,
        left: 210.w,
        child: Image.asset("assets/images/logo_no_bg.png", width: 50.w,),
      )
    );

    children.add(
      Positioned(
        top: offsets[3].dx - 8.h,
        left: offsets[3].dy - 2.w,
        child: Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        )
      )
    );

    Stack stack = Stack(
      children: children,
    );
    return stack;
  }

  void startGame(){
    int difficulty = selectorKey.currentState!.index;
    Navigator.push(context, MaterialPageRoute(builder: (context) => MazePage(difficulty: difficulty)));
  }

  @override
  Widget build(BuildContext context) {
    Stack titolo = creaStackTitolo();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250.h,
              margin: EdgeInsets.only(bottom: 30.h),
              child: titolo,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 200.w),
              margin: EdgeInsets.only(bottom: 80.h),
              child: Text("Inclina il tuo telefono per muovere la pallina lungo il labirinto e raggiungi l'uscita!", style: TextStyle(fontSize: 15.w), textAlign: TextAlign.center),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(padding: EdgeInsets.only(bottom: 10.h), child: Text("Difficoltà", style: TextStyle(fontSize: 15.w))),
            ),
            SwipeSelector(key: selectorKey),
            SizedBox(height: 150.h),
            ElevatedButton(
              onPressed: startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.w),
                ),
                elevation: 6,
                shadowColor: Colors.black45,
              ),
              child: Text(
                "Inizia Partita",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )

          ],
        )
      ),
    );
  }
}