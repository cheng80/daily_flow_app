import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';

class Home extends StatefulWidget {
  final VoidCallback onToggleTheme;
  
  const Home({super.key, required this.onToggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Property
  //late 는 초기화를 나중으로 미룸
  late bool _themeBool;

  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
    _themeBool = false;
  }
  
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근
    
    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText( "Home" , style: TextStyle(color: p.textPrimary) ),
        actions: [
          Switch(
            value: _themeBool,
            onChanged: (value) {
              setState(() {
                _themeBool = value;
              });
              widget.onToggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: CustomColumn(
          children:[
            CustomText("Home Page", style: TextStyle(color: p.textPrimary) ),
           
          ]
        ),
      ),
    );
  }


  //--------Functions ------------
  
  //------------------------------
}