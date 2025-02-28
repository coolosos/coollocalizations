extension Formatter on String {
  colorizeMessage(
    PrinterStringColor color, {
    required String emoji,
  }) =>
      "$emoji ${color.color}$this${PrinterStringColor.reset.color}";
}

enum PrinterStringColor {
  reset(color: '\x1B[0m'),
  black(color: '\x1B[30m'),
  red(color: '\x1B[31m'),
  green(color: '\x1B[32m'),
  yellow(color: '\x1B[33m'),
  blue(color: '\x1B[34m'),
  magenta(color: '\x1B[35m'),
  cyan(color: '\x1B[36m'),
  white(color: '\x1B[37m'),
  ;

  const PrinterStringColor({required this.color});

  final String color;
}
