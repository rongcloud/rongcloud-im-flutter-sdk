import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'router.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: Routers.routerMap(context),
      theme: ThemeData(primaryColor: Colors.blue),
      home: HomePage(),
    );
  }
  
}
