import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moto_gp/calculations_bloc/calculations_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  final CalculationsBloc calculationsBloc;
  const HomePage({super.key, required this.calculationsBloc});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.calculationsBloc.add(Reset());

        return Future.value(true);
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<CalculationsBloc, CalculationsState>(
            bloc: widget.calculationsBloc,
            builder: (context, state) {
              if (state is! CalculationsSuccess) {
                return Center(
                  child: Text(state.toString()),
                );
              }

              return Center(
                child: Column(
                  children: [
                    SfRadialGauge(
                      enableLoadingAnimation: true,
                      animationDuration: 2000,
                      axes: [
                        RadialAxis(
                          ranges: [
                            GaugeRange(
                              startValue: -100,
                              endValue: 100,
                              gradient: const SweepGradient(
                                colors: [Colors.red, Colors.green, Colors.red],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ],
                          minimum: -100.0,
                          maximum: 100.0,
                          pointers: [
                            NeedlePointer(value: state.meanAngle),
                          ],
                        ),
                      ],
                    ),
                    const Text("raw pitch:"),
                    Text(state.initialPitch.toStringAsPrecision(3)),
                    const Text("raw roll:"),
                    Text(state.initialRoll.toStringAsPrecision(3)),
                    const Text("raw yaw:"),
                    Text(state.initialYaw.toStringAsPrecision(3)),
                    const Text("calibrated pitch:"),
                    Text(state.calibratedPitch.toStringAsPrecision(3)),
                    const Text("calibrated roll:"),
                    Text(state.calibratedRoll.toStringAsPrecision(3)),
                    const Text("calibrated yaw:"),
                    Text(state.calibratedYaw.toStringAsPrecision(3)),
                    const Text(
                      "mean angle:",
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      state.meanAngle.toStringAsPrecision(3),
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.calculationsBloc.add(Reset());
                        Navigator.of(context).pop();
                      },
                      child: const Text("Go back"),
                    ),
                  ],
                ),
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
      ),
    );
  }
}
