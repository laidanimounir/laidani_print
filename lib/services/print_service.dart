import 'dart:io';
import 'package:flutter/foundation.dart';

class PrintOptions {
  final int copies;
  final String colorMode;
  final String paperSize;
  final bool isDuplex;

  PrintOptions({
    this.copies = 1,
    this.colorMode = 'bw',
    this.paperSize = 'A4',
    this.isDuplex = false,
  });
}

class PrintService {
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  Future<List<String>> getAvailablePrinters() async {
    if (!isDesktop) return [];

    try {
      if (Platform.isWindows) {
        final result = await Process.run('wmic', ['printer', 'get', 'name']);
        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n').skip(1);
          return lines
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error getting printers: $e');
    }
    return [];
  }

  Future<bool> printFile(String filePath, PrintOptions options) async {
    if (!isDesktop) {
      debugPrint('Printing only available on desktop');
      return false;
    }

    try {
      if (Platform.isWindows) {
        final printArgs = <String>[
          '/c',
          'print',
          if (options.copies > 1) '/d:${options.copies}',
          filePath,
        ];
        final result = await Process.run('cmd', printArgs);
        return result.exitCode == 0;
      }
    } catch (e) {
      debugPrint('Error printing: $e');
    }
    return false;
  }

  // duplex: step1 odd pages, step2 even pages reversed
  Future<bool> printDuplexStep1(String filePath) async {
    debugPrint('Duplex Step 1: Printing odd pages of $filePath');
    return printFile(filePath, PrintOptions(isDuplex: false));
  }

  Future<bool> printDuplexStep2(String filePath) async {
    debugPrint('Duplex Step 2: Printing even pages of $filePath (reverse side)');
    return printFile(filePath, PrintOptions(isDuplex: false));
  }

  Future<bool> printReceipt(String orderNumber, double price, double? change) async {
    debugPrint('Printing receipt for order $orderNumber');
    debugPrint('Amount: $price DZD');
    if (change != null && change > 0) {
      debugPrint('Change: $change DZD');
    }
    return true;
  }
}
