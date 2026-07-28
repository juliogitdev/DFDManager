import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../database/database_helper.dart';
import '../models/dfd.dart';
import '../state/dfd_list_filter.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  final _filter = DfdListFilter.instance;
  final _searchCtrl = TextEditingController();

  static final _df = DateFormat('dd/MM/yyyy');

  late Future<List<Dfd>> _dfdsFuture;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = _filter.texto;
    _refresh();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _dfdsFuture = _db.queryDfds(
        texto: _filter.texto,
        dataInicio: _filter.dataInicio,
        dataFim: _filter.dataFim,
        sort: _filter.sort,
      );
    });
  }

  void _onSearch(String value) {
    _filter.texto = value;
    _refresh();
  }

  static String _sortLabel(DfdSort s) {
    switch (s) {
      case DfdSort.maisRecente:
        return 'Mais recente';
      case DfdSort.maisAntiga:
        return 'Mais antiga';
      case DfdSort.codigoAsc:
        return 'Código (A–Z)';
      case DfdSort.justificativaAsc:
        return 'Justificativa (A–Z)';
    }
  }

  Future<void> _deletar(Dfd dfd) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir a DFD ${dfd.codigo}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
              const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteDfd(dfd.id!);
      _refresh();
    }
  }

  Future<void> _abrirFiltros() async {
    DateTime? inicio = _filter.dataInicio;
    DateTime? fim = _filter.dataFim;
    DfdSort sort = _filter.sort;

    final aplicou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            Future<void> pick(bool isInicio) async {
              final base = isInicio
                  ? (inicio ?? DateTime.now())
                  : (fim ?? inicio ?? DateTime.now());
              final picked = await showDatePicker(
                context: ctx,
                initialDate: base,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setModal(() {
                  if (isInicio) {
                    inicio = picked;
                    if (fim != null && fim!.isBefore(picked)) fim = picked;
                  } else {
                    fim = picked;
                    if (inicio != null && inicio!.isAfter(picked)) {
                      inicio = picked;
                    }
                  }
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Filtrar e ordenar',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Intervalo de datas (sobre a Data da DFD)
                  const Text('Intervalo de datas (Data da DFD)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _campoData(
                          'De',
                          inicio,
                              () => pick(true),
                              () => setModal(() => inicio = null),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _campoData(
                          'Até',
                          fim,
                              () => pick(false),
                              () => setModal(() => fim = null),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ordenação
                  const Text('Ordenar por',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DfdSort.values.map((opt) {
                      return ChoiceChip(
                        label: Text(_sortLabel(opt)),
                        selected: sort == opt,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        onSelected: (_) => setModal(() => sort = opt),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModal(() {
                              inicio = null;
                              fim = null;
                              sort = DfdSort.maisRecente;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (aplicou == true) {
      setState(() {
        _filter.dataInicio = inicio;
        _filter.dataFim = fim;
        _filter.sort = sort;
      });
      _refresh();
    }
  }

  Widget _campoData(
      String label, DateTime? value, VoidCallback onTap, VoidCallback onClear) {
    final preenchido = value != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                preenchido ? _df.format(value!) : label,
                style: TextStyle(
                    color: preenchido ? Colors.black87 : Colors.grey),
              ),
            ),
            if (preenchido)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chipsAtivos() {
    final chips = <Widget>[];

    if (_filter.temFiltroData) {
      final ini =
      _filter.dataInicio != null ? _df.format(_filter.dataInicio!) : '…';
      final fim =
      _filter.dataFim != null ? _df.format(_filter.dataFim!) : '…';
      chips.add(_chip(Icons.date_range, '$ini – $fim', () {
        setState(() => _filter.limparDatas());
        _refresh();
      }));
    }

    if (_filter.sort != DfdSort.maisRecente) {
      chips.add(_chip(Icons.sort, _sortLabel(_filter.sort), () {
        setState(() => _filter.resetarOrdenacao());
        _refresh();
      }));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _chip(IconData icon, String label, VoidCallback onRemove) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFE0E0E0)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DFD Manager'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filtrar e ordenar',
            onPressed: _abrirFiltros,
            icon: Badge(
              isLabelVisible: _filter.temFiltroData ||
                  _filter.sort != DfdSort.maisRecente,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (result == true) _refresh();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova DFD'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por código ou justificativa...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                suffixIcon: _filter.texto.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white60),
                  onPressed: () {
                    _searchCtrl.clear();
                    _onSearch('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Chips de filtros ativos
          _chipsAtivos(),

          // Lista
          Expanded(
            child: FutureBuilder<List<Dfd>>(
              future: _dfdsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  final filtrando = _filter.ativo;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          filtrando
                              ? 'Nenhuma DFD encontrada para os filtros atuais.'
                              : 'Nenhuma DFD cadastrada ainda.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (filtrando) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _filter.limparTudo());
                              _refresh();
                            },
                            child: const Text('Limpar filtros'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final dfds = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dfds.length,
                  itemBuilder: (context, index) {
                    final dfd = dfds[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            dfd.codigo.length >= 2
                                ? dfd.codigo.substring(0, 2).toUpperCase()
                                : dfd.codigo.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          dfd.codigo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Data DFD: ${dfd.dataDfdFormatada}',
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              dfd.justificativa,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _deletar(dfd),
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                dfd: dfd,
                                onChanged: _refresh,
                              ),
                            ),
                          );
                          if (result == true) _refresh();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}