import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class QemuService {
  static const String _qemuBinary = 'qemu-system-x86_64';
  
  Process? _qemuProcess;
  int _vncPort = 5900;

  Future<String> getQemuPath() async {
    // Copiar QEMU dos assets para o app
    final appDir = await getApplicationDocumentsDirectory();
    final qemuPath = '${appDir.path}/$_qemuBinary';
    
    final file = File(qemuPath);
    if (!await file.exists()) {
      // Copiar do assets
      final byteData = await rootBundle.load('assets/qemu/$_qemuBinary');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      // Tornar executável
      await Process.run('chmod', ['+x', qemuPath]);
    }
    return qemuPath;
  }

  Future<void> createDisk({
    required String path,
    required int sizeGB,
  }) async {
    await Process.run('qemu-img', [
      'create',
      '-f', 'qcow2',
      path,
      '${sizeGB}G',
    ]);
  }

  Future<void> startVM({
    required String imagePath,
    required int ramGB,
    required String? isoPath,
    required int vncPort,
  }) async {
    final qemuPath = await getQemuPath();
    _vncPort = vncPort;

    List<String> args = [
      '-m', (ramGB * 1024).toString(), // RAM em MB
      '-hda', imagePath,
      '-vnc', '0.0.0.0:$vncPort',
      '-net', 'user',
      '-net', 'nic',
      '-accel', 'tcg',
      '-usb',
      '-device', 'usb-tablet',
      '-display', 'none',
    ];

    if (isoPath != null && isoPath.isNotEmpty) {
      args.addAll(['-cdrom', isoPath]);
    }

    _qemuProcess = await Process.start(qemuPath, args);
    
    // Monitorar saída
    _qemuProcess?.stdout.listen((data) {
      print('QEMU stdout: ${String.fromCharCodes(data)}');
    });
    _qemuProcess?.stderr.listen((data) {
      print('QEMU stderr: ${String.fromCharCodes(data)}');
    });
  }

  Future<void> stopVM() async {
    if (_qemuProcess != null) {
      _qemuProcess?.kill();
      _qemuProcess = null;
    }
  }

  bool isRunning() {
    return _qemuProcess != null;
  }

  int getVncPort() {
    return _vncPort;
  }
}
