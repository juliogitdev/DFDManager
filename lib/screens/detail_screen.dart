import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/dfd.dart';
import 'form_screen.dart';

class DetailScreen extends StatefulWidget {
  final Dfd dfd;
  final VoidCallback onChanged;

  const DetailScreen({super.key, required this.dfd, required this.onChanged});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _db = DatabaseHelper();
  late Dfd _dfd;

  @override
  void initState() {
    super.initState();
    _dfd = widget.dfd;
  }

  Future<void> _reloadDfd() async {
    final all = await _db.getAllDfds();
    final updated = all.where((d) => d.id == _dfd.id).firstOrNull;
    if (updated != null && mounted) {
      setState(() => _dfd = updated);
    }
  }

  void _compartilhar() {
    final texto = '''
📄 DFD - Formalização de Demanda

Código: ${_dfd.codigo}
Data da DFD: ${_dfd.dataDfdFormatada}
Registrado em: ${_dfd.dataCriacaoFormatada}

Justificativa:
${_dfd.justificativa}
''';
    Share.share(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DFD ${_dfd.codigo}'),
        backgroundColor: AppColors.primary,
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
                    builder: (_) => FormScreen(dfd: _dfd)),
              );
              if (result == true) {
                widget.onChanged();
                await _reloadDfd();
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
            _card('Código', _dfd.codigo, Icons.tag),
            _card('Data da DFD', _dfd.dataDfdFormatada, Icons.description),
            _card('Registrado no app', _dfd.dataCriacaoFormatada, Icons.today),
            _card('Justificativa', _dfd.justificativa, Icons.notes,
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
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