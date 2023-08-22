import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moto_gp/calculations_bloc/calculations_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CalculationsBloc, CalculationsState>(
          bloc: BlocProvider.of<CalculationsBloc>(context),
          builder: (context, state) {
            if (state is! CalculationsSuccess) {
              return Center(
                child: Text(state.toString()),
              );
            }

            return Center(
              child: Text(state.accelerometerValues.toString()),
            );

            // return Center(
            //   child: SfRadialGauge(
            //     enableLoadingAnimation: true,
            //     animationDuration: 2000,
            //     axes: [
            //       RadialAxis(
            //         ranges: [
            //           GaugeRange(
            //             startValue: -50,
            //             endValue: 50,
            //             gradient: const SweepGradient(
            //               colors: [Colors.red, Colors.green, Colors.red],
            //               stops: [0.0, 0.5, 1.0],
            //             ),
            //           ),
            //         ],
            //         minimum: -50.0,
            //         maximum: 50.0,
            //         pointers: [
            //           NeedlePointer(value: state.angle),
            //         ],
            //       ),
            //     ],
            //   ),
            // );
          },
        ),
      ),
    );
  }
}
