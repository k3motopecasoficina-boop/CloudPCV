import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloudvm_real/models/vm_model.dart';
import 'package:cloudvm_real/services/vm_service.dart';

class VMScreen extends StatefulWidget {
  final VMModel vm;

  const VMScreen({super.key, required this.vm});

  @override
  State<VMScreen> createState() => _VMScreenState();
}

class _VMScreenState extends State<VMScreen> {
  final VMService _vmService = VMService();
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final vncPort = _vmService.getVncPort();
    final vncUrl = 'http://localhost:$vncPort';
    
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erro ao conectar: ${error.errorCode}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(vncUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.vm.icon),
            const SizedBox(width: 8),
            Text(widget.vm.name),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '🔴 AO VIVO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              _showKeyboard ? Icons.keyboard_off : Icons.keyboard,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _showKeyboard = !_showKeyboard),
          ),
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // VNC Viewer
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    '🔄 Conectando à VM...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          WebViewWidget(controller: _webViewController),

          // Teclado Virtual
          if (_showKeyboard)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: _buildKeyboard(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyboard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Linha 1
        _buildKeyRow(['ESC', 'TAB', 'CTRL', 'ALT', 'SHIFT']),
        const SizedBox(height: 4),
        // Linha 2
        _buildKeyRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']),
        const SizedBox(height: 4),
        // Linha 3
        _buildKeyRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']),
        const SizedBox(height: 4),
        // Linha 4
        _buildKeyRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫']),
        const SizedBox(height: 4),
        // Linha 5
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('ESPACO', width: 200),
            _buildKey('ENTER', width: 80, color: Colors.green),
            _buildKey('FECHAR', width: 80, color: Colors.red, onTap: () {
              setState(() => _showKeyboard = false);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key, {double width = 36, Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap ?? () {
          // Enviar tecla para a VM via VNC
          _sendKey(key);
        },
        child: Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                color: Colors.white,
                fontSize: key.length > 3 ? 10 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendKey(String key) {
    // Enviar tecla para a VM via VNC
    // Implementar usando WebView JavaScript injection
    _webViewController.runJavaScript('''
      // Simular tecla pressionada
      var event = new KeyboardEvent('keydown', {key: '$key'});
      document.dispatchEvent(event);
    ''');
  }
}
