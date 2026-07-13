import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vm_model.dart';

class StorageService {
  static const String _vmsKey = 'cloudvm_vms';
  static const String _cloudVMDir = 'CloudVM';

  Future<Directory> getCloudVMDir() async {
    final appDir = await getExternalStorageDirectory();
    final cloudDir = Directory('${appDir?.path}/$_cloudVMDir');
    if (!await cloudDir.exists()) {
      await cloudDir.create(recursive: true);
    }
    return cloudDir;
  }

  Future<Directory> getVMsDir() async {
    final cloudDir = await getCloudVMDir();
    final vmsDir = Directory('${cloudDir.path}/vms');
    if (!await vmsDir.exists()) {
      await vmsDir.create(recursive: true);
    }
    return vmsDir;
  }

  Future<Directory> getISOsDir() async {
    final cloudDir = await getCloudVMDir();
    final isosDir = Directory('${cloudDir.path}/isos');
    if (!await isosDir.exists()) {
      await isosDir.create(recursive: true);
    }
    return isosDir;
  }

  Future<void> saveVMs(List<VMModel> vms) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> vmJson = vms.map((vm) => jsonEncode(vm.toJson())).toList();
    await prefs.setStringList(_vmsKey, vmJson);
  }

  Future<List<VMModel>> loadVMs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? vmJson = prefs.getStringList(_vmsKey);
    if (vmJson == null) return [];
    return vmJson.map((json) => VMModel.fromJson(jsonDecode(json))).toList();
  }

  Future<void> deleteVM(VMModel vm) async {
    // Deletar arquivo do disco
    final file = File(vm.imagePath);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Remover da lista
    final vms = await loadVMs();
    vms.removeWhere((v) => v.id == vm.id);
    await saveVMs(vms);
  }
}
