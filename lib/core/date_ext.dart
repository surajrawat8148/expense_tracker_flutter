extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
  String ym() => '$year-${month.toString().padLeft(2, '0')}';
}
