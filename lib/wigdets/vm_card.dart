import 'package:flutter/material.dart';
import 'package:cloudvm_real/models/vm_model.dart';

class VMCard extends StatelessWidget {
  final VMModel vm;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const VMCard({
    super.key,
    required this.vm,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4FACFE).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              vm.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              vm.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            if (vm.status == 'installing')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'INSTALANDO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            if (vm.status == 'on')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIGADA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '💾 ${vm.storage}GB · 🧠 ${vm.ram}GB · ${vm.os}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 14,
                  color: vm.status == 'on' ? Colors.green : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  vm.status == 'on' ? '🟢 Rodando' : '🔴 Desligada',
                  style: TextStyle(
                    fontSize: 12,
                    color: vm.status == 'on' ? Colors.green : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.code,
                  size: 14,
                  color: Colors.blue[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'QEMU',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[400],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
