import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moto_gp/calibration_page.dart';

import 'calculations_bloc/calculations_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  // This widget is the root of your application.

  final CalculationsBloc calculationBloc = CalculationsBloc();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test MotoGP',
      home: CalibrationPage(calculationBloc),
    );
  }
}
