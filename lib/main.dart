import 'package:ScanKar/constants.dart';

import './route_generator.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanKar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(primaryColor: Constants.MAIN_COLOR),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
