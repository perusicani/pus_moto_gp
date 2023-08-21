import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moto_gp/calculations_bloc/calculations_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalculationsBloc _calculationsBloc;

  @override
  void initState() {
    _calculationsBloc = CalculationsBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CalculationsBloc, CalculationsState>(
          bloc: _calculationsBloc,
          builder: (context, state) {
            if (state is! CalculationsSuccess) {
              return Center(
                child: Text(state.toString()),
              );
            }

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
            //           NeedlePointer(value: state.angle)
            //         ],
            //       ),
            //     ],
            //   ),
            // );
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "accelero: ${state.accelerometerValues!.map((e) => e.toStringAsFixed(2)).toList().join(", ")}"),
                  Text(
                      "gyro: ${state.gyroscopeValues!.map((e) => e.toStringAsFixed(2)).toList().join(", ")}"),
                  ElevatedButton(
                    onPressed: () => _calculationsBloc.setWriteBool('still'),
                    child: const Text("save stand still values"),
                  ),
                  ElevatedButton(
                    onPressed: () => _calculationsBloc.setWriteBool('forward'),
                    child: const Text("save forward no angle values"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _calculationsBloc.setWriteBool('still_left'),
                    child: const Text("save stand still left lean values"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _calculationsBloc.setWriteBool('still_right'),
                    child: const Text("save stand still right lean values"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _calculationsBloc.setWriteBool('forward_left'),
                    child: const Text("save forward left lean values"),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        _calculationsBloc.setWriteBool('forward_right'),
                    child: const Text("save forward right lean values"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
