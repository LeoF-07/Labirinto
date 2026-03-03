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
    Offset(140.w, 80.h),
    Offset(140.w, 110.h),
    Offset(140.w, 140.h),
    Offset(170.w, 140.h),
    Offset(200.w, 140.h),
    Offset(200.w, 110.h),
    Offset(200.w, 80.h),
    Offset(230.w, 80.h),
    Offset(260.w, 80.h),

    Offset(230.w, 120.h) // Offset immagine
  ];
  
  final List charsOfTitle = "LABIRINTO".split("");

  Stack creaStackTitolo(){
    List<Positioned> children = [];

    for(int i = 0; i < charsOfTitle.length; i++){
      children.add(
        Positioned(
          top: offsets[i].dy,
          left: offsets[i].dx,
          child: Text(charsOfTitle[i], style: TextStyle(fontSize: 20.w)),
        )
      );
    }
    
    children.add(
      Positioned(
        top: offsets.last.dy,
        left: offsets.last.dx,
        child: Image.asset("assets/images/logo_no_bg.png", width: 50.w,),
      )
    );

    children.add(
      Positioned(
        top: offsets[3].dy - 8.h,
        left: offsets[3].dx - 2.w,
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => MazePage(difficulty: difficulty, tiltX: tiltX, tiltY: tiltY, tiltUp: tiltUp)));
  }

  double tiltX = 30;
  double tiltY = 30;
  double tiltUp = 30;

  @override
  Widget build(BuildContext context) {
    Stack titolo = creaStackTitolo();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 220.h,
              margin: EdgeInsets.only(bottom: 10.h),
              child: titolo,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 200.w),
              margin: EdgeInsets.only(bottom: 50.h),
              child: Text("Inclina il tuo telefono per muovere la pallina lungo il labirinto e raggiungi l'uscita!", style: TextStyle(fontSize: 15.w), textAlign: TextAlign.center),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(padding: EdgeInsets.only(bottom: 10.h), child: Text("Difficoltà", style: TextStyle(fontSize: 15.w))),
            ),
            SwipeSelector(key: selectorKey),
            Align(
              alignment: Alignment.center,
              child: Padding(padding: EdgeInsets.only(bottom: 10.h), child: Text("Impostazioni accelerometro:", style: TextStyle(fontSize: 15.w))),
            ),
            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 10.w), child: Text("TiltX:  "),),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.orange,
                        inactiveTrackColor: Colors.grey[400],
                        thumbColor: Colors.orange,
                        overlayColor: Colors.orange.withAlpha(20),
                    ),
                    child: Slider(
                      value: tiltX,
                      min: 10,
                      max: 40,
                      divisions: 30,
                      label: tiltX.toStringAsFixed(0),
                      onChanged: (v) => setState(() {tiltX = v;})
                    )
                  )
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 10.w), child: Text("TiltY:  ")),
                Expanded(
                    child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.grey[400],
                          thumbColor: Colors.orange,
                          overlayColor: Colors.orange.withAlpha(20),
                        ),
                        child: Slider(
                            value: tiltY,
                            min: 10,
                            max: 40,
                            divisions: 30,
                            label: tiltY.toStringAsFixed(0),
                            onChanged: (v) => setState(() {tiltY = v;})
                        )
                    )
                )
              ],
            ),

            Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 10.w), child: Text("TiltUp:")),
                Expanded(
                    child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.grey[400],
                          thumbColor: Colors.orange,
                          overlayColor: Colors.orange.withAlpha(20),
                        ),
                        child: Slider(
                            value: tiltUp,
                            min: 10,
                            max: 40,
                            divisions: 30,
                            label: tiltUp.toStringAsFixed(0),
                            onChanged: (v) => setState(() {tiltUp = v;})
                        )
                    )
                )
              ],
            ),
            SizedBox(height: 40.h),
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