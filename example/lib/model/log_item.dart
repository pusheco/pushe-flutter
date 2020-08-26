enum Type { option, event, result}
enum LogType { normal, interactive }

class LogItem {
  final String tag, message;
  final Type type;
  final Map<String, String> data;
  final DateTime date;

  LogItem({this.tag, this.message, this.data = const {}, this.type = Type.option, this.date});
}