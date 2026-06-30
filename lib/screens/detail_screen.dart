import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dfd.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final Dfd dfd;
  final VoidCallback onChanged;

  const DetailScreen({super.key, required this.dfd, required this.onChanged});

  void _compartilhar() {
    final texto = '''
📄 DFD - Formalização de Demanda

Código: ${dfd.codigo}
Data da DFD: ${dfd.dataDfd}
Registrado em: ${dfd.dataCriacao}

Justificativa:
${dfd.justificativa}
''';
    Share.share(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DFD ${dfd.codigo}'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
            onPressed: _compartilhar,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FormScreen(dfd: dfd)),
              );
              if (result == true) {
                onChanged();
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card('Código', dfd.codigo, Icons.tag),
            _card('Data da DFD', dfd.dataDfd, Icons.description),
            _card('Registrado no app', dfd.dataCriacao, Icons.today),
            _card('Justificativa', dfd.justificativa, Icons.notes,
                multiline: true),
          ],
        ),
      ),
    );
  }

  Widget _card(String label, String value, IconData icon,
      {bool multiline = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: multiline ? 14 : 16,
                  fontWeight:
                  multiline ? FontWeight.normal : FontWeight.bold)),
        ],
      ),
    );
  }
}