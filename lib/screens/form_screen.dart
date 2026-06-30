import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/dfd.dart';

class FormScreen extends StatefulWidget {
  final Dfd? dfd;

  const FormScreen({super.key, this.dfd});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();

  late TextEditingController _codigoCtrl;
  late TextEditingController _justificativaCtrl;

  DateTime? _dataDfd;
  DateTime? _dataCriacao;

  bool get isEditing => widget.dfd != null;

  @override
  void initState() {
    super.initState();
    _codigoCtrl = TextEditingController(text: widget.dfd?.codigo ?? '');
    _justificativaCtrl =
        TextEditingController(text: widget.dfd?.justificativa ?? '');

    if (isEditing) {
      _dataDfd = DateFormat('dd/MM/yyyy').parse(widget.dfd!.dataDfd);
      _dataCriacao = DateFormat('dd/MM/yyyy').parse(widget.dfd!.dataCriacao);
    }
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _justificativaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDfd) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDfd) {
          _dataDfd = picked;
        } else {
          _dataCriacao = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Selecionar data';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataDfd == null || _dataCriacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha as duas datas.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dfd = Dfd(
      id: widget.dfd?.id,
      codigo: _codigoCtrl.text.trim(),
      dataDfd: _formatDate(_dataDfd),
      dataCriacao: _formatDate(_dataCriacao),
      justificativa: _justificativaCtrl.text.trim(),
    );

    if (isEditing) {
      await _db.updateDfd(dfd);
    } else {
      await _db.insertDfd(dfd);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'DFD atualizada!' : 'DFD cadastrada!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar DFD' : 'Nova DFD'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Código
              const Text('Código da DFD',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _codigoCtrl,
                decoration: _inputDecoration('Ex: DFD-2024-001'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Informe o código' : null,
              ),
              const SizedBox(height: 20),

              // Data da DFD
              const Text('Data da DFD (sistema oficial)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _dateButton(_formatDate(_dataDfd), () => _pickDate(true)),
              const SizedBox(height: 20),

              // Data de criação no app
              const Text('Data de criação (registro no app)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _dateButton(_formatDate(_dataCriacao), () => _pickDate(false)),
              const SizedBox(height: 20),

              // Justificativa
              const Text('Justificativa',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _justificativaCtrl,
                decoration: _inputDecoration('Descreva a justificativa da DFD'),
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a justificativa'
                    : null,
              ),
              const SizedBox(height: 32),

              // Botão salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isEditing ? 'Salvar Alterações' : 'Cadastrar DFD',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget _dateButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF1A237E)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: label == 'Selecionar data'
                        ? Colors.grey
                        : Colors.black87)),
          ],
        ),
      ),
    );
  }
}