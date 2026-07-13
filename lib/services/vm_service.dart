import 'dart:io';
import 'package:cloudvm_real/models/vm_model.dart';
import 'package:cloudvm_real/services/storage_service.dart';
import 'package:cloudvm_real/services/qemu_service.dart';

class VMService {
  final StorageService _storage = StorageService();
  final QemuService _qemu = QemuService();
  String? _currentVMId;

  Future<List<VMModel>> getAllVMs() async {
    return await _storage.loadVMs();
  }

  Future<VMModel?> getVM(String id) async {
    final vms = await getAllVMs();
    try {
      return vms.firstWhere((vm) => vm.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createVM({
    required String name,
    required String os,
    required String osKey,
    required String icon,
    required int storage,
    required int ram,
    required String isoPath,
  }) async {
    final vms = await getAllVMs();
    
    // Limite de 15 VMs
    if (vms.length >= 15) {
      vms.removeAt(0);
    }

    final vmsDir = await _storage.getVMsDir();
    final imagePath = '${vmsDir.path}/${name.replaceAll(' ', '_')}.qcow2';
    
    // Criar disco virtual
    await _qemu.createDisk(
      path: imagePath,
      sizeGB: storage,
    );

    final newVM = VMModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      os: os,
      osKey: osKey,
      icon: icon,
      storage: storage,
      ram: ram,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      isoPath: isoPath,
    );

    vms.add(newVM);
    await _storage.saveVMs(vms);
  }

  Future<void> startVM(String id) async {
    final vm = await getVM(id);
    if (vm == null) return;

    _currentVMId = id;
    final vncPort = 5900 + (int.parse(vm.id) % 10);
    
    await _qemu.startVM(
      imagePath: vm.imagePath,
      ramGB: vm.ram,
      isoPath: vm.status == 'installing' ? vm.isoPath : null,
      vncPort: vncPort,
    );

    // Atualizar status
    final updatedVM = vm.copyWith(status: 'on');
    final vms = await getAllVMs();
    final index = vms.indexWhere((v) => v.id == id);
    if (index != -1) {
      vms[index] = updatedVM;
      await _storage.saveVMs(vms);
    }
  }

  Future<void> stopVM(String id) async {
    await _qemu.stopVM();
    
    final vm = await getVM(id);
    if (vm != null) {
      final updatedVM = vm.copyWith(status: 'off');
      final vms = await getAllVMs();
      final index = vms.indexWhere((v) => v.id == id);
      if (index != -1) {
        vms[index] = updatedVM;
        await _storage.saveVMs(vms);
      }
    }
    _currentVMId = null;
  }

  Future<void> deleteVM(String id) async {
    final vm = await getVM(id);
    if (vm != null) {
      if (vm.status == 'on') {
        await stopVM(id);
      }
      await _storage.deleteVM(vm);
    }
  }

  bool isVMRunning() {
    return _qemu.isRunning();
  }

  int getVncPort() {
    return _qemu.getVncPort();
  }

  String? getCurrentVMId() {
    return _currentVMId;
  }
}
