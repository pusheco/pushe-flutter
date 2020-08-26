import 'package:bloc/bloc.dart';
import 'package:pushe_example/model/log_state.dart';
import 'log_item.dart';

class LogCubit extends Cubit<LogState> {
  LogCubit() : super(LogState(logs: []));

  void addLog(LogItem log) {
    emit(LogState(logs: state.logs..add(log)));
  }
}