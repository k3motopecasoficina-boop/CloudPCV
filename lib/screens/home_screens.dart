import 'package:flutter/material.dart';
import 'package:cloudvm_real/models/vm_model.dart';
import 'package:cloudvm_real/services/vm_service.dart';
import 'package:cloudvm_real/widgets/vm_card.dart';
import 'package:cloudvm_real/screens/create_vm_screen.dart';
import 'package:cloudvm_real/screens/vm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VMService _vmService = VMService();
  List<VMModel> _vms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVMs();
  }

  Future<void> _loadVMs() async {
    setState(() => _isLoading = true);
    _vms = await _vmService.getAllVMs();
    setState(() => _isLoading = false);
  }

  void _openCreateVM() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateVMScreen()),
    );
    if (result == true) {
      _loadVMs();
    }
  }

  void _openVM(VMModel vm) async {
    if (vm.status == 'off') {
      // Iniciar VM
      await _vmService.startVM(vm.id);
      await _loadVMs();
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VMScreen(vm: vm),
        fullscreenDialog: true,
      ),
    ).then((_) async {
      await _vmService.stopVM(vm.id);
      await _loadVMs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.cloud, color: Color(0xFF4FACFE)),
            const SizedBox(width: 8),
            const Text(
              'CloudVM',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'REAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ℹ️ Sobre o CloudVM'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🖥️ VMs REAIS com QEMU'),
                      Text('💾 Discos virtuais .qcow2'),
                      Text('🔄 Windows/Linux/Ubuntu'),
                      Text('📱 Até 15 VMs'),
                      Text('📂 Apps ORIGINAIS'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Status Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatusCard(
                        icon: Icons.computer,
                        label: 'Total',
                        value: _vms.length.toString(),
                        color: const Color(0xFF4FACFE),
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCard(
                        icon: Icons.check_circle,
                        label: 'Ativas',
                        value: _vms.where((v) => v.status == 'on').length.toString(),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusCard(
                        icon: Icons.storage,
                        label: 'Limite',
                        value: '15',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                // Lista de VMs
                Expanded(
                  child: _vms.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _vms.length,
                          itemBuilder: (context, index) {
                            return VMCard(
                              vm: _vms[index],
                              onTap: () => _openVM(_vms[index]),
                              onDelete: () async {
                                await _vmService.deleteVM(_vms[index].id);
                                _loadVMs();
                              },
                            );
                          },
                        ),
                ),

                // Botão Criar VM
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _openCreateVM,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FACFE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text(
                          '➕ Criar Nova VM (REAL)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4FACFE).withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FACFE),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma VM criada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clique em "Criar Nova VM (REAL)" para começar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🖥️ VMs REAIS com QEMU',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
