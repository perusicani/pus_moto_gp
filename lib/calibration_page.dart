import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moto_gp/home_page.dart';

import 'calculations_bloc/calculations_bloc.dart';

class CalibrationPage extends StatelessWidget {
  CalibrationPage({super.key});

  final CalculationsBloc calculationBloc = CalculationsBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: BlocBuilder<CalculationsBloc, CalculationsState>(
            bloc: calculationBloc,
            builder: (context, state) {
              if (state is ReadyToCollectData) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () =>
                    //       calculationBloc.add(StartTiltCalibration()),
                    //   child: const Text("Tilt calibration"),
                    // ),
                    // if (calculationBloc.tiltVals != null)
                    //   Text(calculationBloc.tiltVals.toString()),
                    // ElevatedButton(
                    //   onPressed: () =>
                    //       calculationBloc.add(StartUprightCalibration()),
                    //   child: const Text("Upright calibration"),
                    // ),
                    // if (calculationBloc.flatVals != null)
                    //   Text(calculationBloc.flatVals.toString()),
                    ElevatedButton(
                      onPressed: () =>
                          calculationBloc.add(StartRotationCalibration()),
                      child: const Text("Rotation calibration"),
                    ),
                    if (calculationBloc.calibration != null)
                      Text(
                        "x: ${calculationBloc.calibration!.x}, y: ${calculationBloc.calibration!.y}, z: ${calculationBloc.calibration!.z}, w: ${calculationBloc.calibration!.w}",
                      ),
                    ElevatedButton(
                      onPressed: () {
                        calculationBloc.startCalculatingAngle();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => calculationBloc,
                              child: HomePage(),
                            ),
                          ),
                        );
                        calculationBloc.add(Calculate());
                      },
                      child: const Text("go to home page"),
                    ),
                  ],
                );
              }
              if (state is CollectingData) {
                return Text(state.seconds.toString());
              }
              return const Text("Something went wrong");
            },
          ),
        ),
      ),
    );
  }
}
