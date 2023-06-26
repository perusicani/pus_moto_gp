import 'package:flutter_bloc/flutter_bloc.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

class CalculationsBloc extends Bloc<CalculationsEvent, CalculationsState> {
  CalculationsBloc() : super(CalculationsInitial()) {
    on<CalculationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
