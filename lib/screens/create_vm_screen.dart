import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudvm_real/services/vm_service.dart';

class CreateVMScreen extends StatefulWidget {
  const CreateVMScreen({super.key});

  @override
  State<CreateVMScreen> createState() => _CreateVMScreenState();
}

class _CreateVMScreenState extends State<CreateVMScreen> {
  final VMService _vmService = VMService();
  String _selectedOS = 'windows10';
  int _storage = 50;
  int _ram = 4;
  String? _isoPath;
  bool _isLoading = false;

  final Map<String, Map<String, String>> _osOptions = {
    'windows10': {
      'name': 'Windows 10',
      'icon': '🪟',
      'iso': 'Win10_22H2.iso',
    },
    'windows11': {
      'name': 'Windows 11',
      'icon': '🪟',
      'iso': 'Win11_22H2.iso',
    },
    'linux': {
      'name': 'Linux',
      'icon': '🐧',
      'iso': 'linux.iso',
    },
    'ubuntu': {
      'name': 'Ubuntu',
      'icon': '🟣',
      'iso': 'ubuntu-22.04.iso',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('📦 Criar VM REAL'),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aviso
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🖥️ VM REAL com QEMU - Instalação completa do SO',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SO
                Text(
                  '🖥️ Sistema Operacional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4FACFE),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: _osOptions.keys.map((key) {
                    final os = _osOptions[key]!;
                    final isSelected = _selectedOS == key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedOS = key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4FACFE).withOpacity(0.1)
                              : const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4FACFE)
                                : const Color(0xFF4FACFE).withOpacity(0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(os['icon']!, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                os['name']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? const Color(0xFF4FACFE)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Armazenamento
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '💾 Armazenamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4FACFE),
                      ),
                    ),
                    Text(
                      '$_storage GB',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _storage.toDouble(),
                  min: 20,
                  max: 200,
                  divisions: 180,
                  onChanged: (value) => setState(() => _storage = value.round()),
                  activeColor: const Color(0xFF4FACFE),
                ),

                const SizedBox(height: 12),

                // RAM
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🧠 Memória RAM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4FACFE),
                      ),
                    ),
                    Text(
                      '$_ram GB',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _ram.toDouble(),
                  min: 2,
                  max: 16,
                  divisions: 14,
                  onChanged: (value) => setState(() => _ram = value.round()),
                  activeColor: const Color(0xFF4FACFE),
                ),

                const SizedBox(height: 20),

                // ISO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isoPath != null
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isoPath != null ? Icons.check_circle : Icons.warning,
                        color: _isoPath != null ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isoPath != null
                                  ? '✅ ISO selecionada'
                                  : '📀 Selecione o arquivo ISO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isoPath != null)
                              Text(
                                _isoPath!.split('/').last,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectISO,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FACFE),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Selecionar'),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Botão Criar
                ElevatedButton(
                  onPressed: _isoPath != null && !_isLoading ? _createVM : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FACFE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '🚀 Criar VM REAL',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectISO() async {
    // Solicitar permissão de armazenamento
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Permissão de armazenamento necessária'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['iso'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isoPath = result.files.single.path;
      });
    }
  }

  Future<void> _createVM() async {
    if (_isoPath == null) return;

    setState(() => _isLoading = true);

    final osInfo = _osOptions[_selectedOS]!;

    try {
      await _vmService.createVM(
        name: osInfo['name']!,
        os: osInfo['name']!,
        osKey: _selectedOS,
        icon: osInfo['icon']!,
        storage: _storage,
        ram: _ram,
        isoPath: _isoPath!,
      );

      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${osInfo['name']} criada com sucesso!\n📀 Instalação iniciada...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao criar VM: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }
}
