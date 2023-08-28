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

            // return Center(
            //   child: Column(
            //     children: state.accelerometerValues!
            //         .map((e) => Text(e.toString()))
            //         .toList(),
            //   ),
            // );

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
                          NeedlePointer(
                              value: state.accelerometerValues!.first * -1),
                        ],
                      ),
                    ],
                  ),
                  Text("kutevi"),
                  Text(state.accelerometerValues![0].toString()),
                  Text(state.accelerometerValues![1].toString()),
                  Text("original"),
                  Text(state.accelerometerValues![2].toString()),
                  Text(state.accelerometerValues![3].toString()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
