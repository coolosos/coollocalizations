import 'extension.dart';
export 'extension.dart';

mixin class PrinterHelper {
  void title(String title) {
    print(
      title
          .toUpperCase()
          .colorizeMessage(PrinterStringColor.magenta, emoji: '✨'),
    );
  }

  void topDivider() {
    print('\n');
    print('----------------------------------------');
  }

  void bottomDivider() {
    print('----------------------------------------');
  }
}
