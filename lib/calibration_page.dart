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
                    ElevatedButton(
                      onPressed: () =>
                          calculationBloc.add(StartTiltCalibration()),
                      child: const Text("Tilt calibration"),
                    ),
                    if (calculationBloc.tiltVals != null)
                      Text(calculationBloc.tiltVals.toString()),
                    ElevatedButton(
                      onPressed: () =>
                          calculationBloc.add(StartUprightCalibration()),
                      child: const Text("Upright calibration"),
                    ),
                    if (calculationBloc.uprightVals != null)
                      Text(calculationBloc.uprightVals.toString()),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => calculationBloc,
                            child: HomePage(),
                          ),
                        ),
                      ),
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
