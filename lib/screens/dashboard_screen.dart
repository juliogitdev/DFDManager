import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../database/database_helper.dart';
import 'form_screen.dart';
import 'home_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper();
  late Future<DfdStats> _statsFuture;

  static final _dataHoraFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _statsFuture = _db.getStats();
    });
  }

  Future<void> _abrirNovaDfd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (result == true) _refresh();
  }

  Future<void> _abrirIndice() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
    if (mounted) _refresh();
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
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<DfdStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _erro();
            }
            final stats = snapshot.data ??
                const DfdStats(
                    total: 0, cadastradasNoMes: 0, ultimaAtualizacao: null);
            return _conteudo(stats);
          },
        ),
      ),
    );
  }

  Widget _erro() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error_outline, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 12),
        const Center(child: Text('Não foi possível carregar o resumo.')),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _refresh,
            child: const Text('Tentar novamente'),
          ),
        ),
      ],
    );
  }

  Widget _conteudo(DfdStats stats) {
    final ultima = stats.ultimaAtualizacao != null
        ? _dataHoraFormat.format(stats.ultimaAtualizacao!)
        : 'Nenhum registro ainda';

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;

        final content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Resumo do índice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Visão geral das DFDs que você está gerenciando.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),

              // Cards de estatística
              if (wide)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _statCard('Total de DFDs', '${stats.total}',
                            Icons.folder_copy, AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                            'Cadastradas neste mês',
                            '${stats.cadastradasNoMes}',
                            Icons.calendar_month,
                            Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard('Última atualização', ultima,
                            Icons.update, Colors.deepOrange,
                            valueFontSize: 15),
                      ),
                    ],
                  ),
                )
              else ...[
                _statCard('Total de DFDs', '${stats.total}',
                    Icons.folder_copy, AppColors.primary,
                    big: true),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _statCard(
                            'Neste mês',
                            '${stats.cadastradasNoMes}',
                            Icons.calendar_month,
                            Colors.teal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard('Atualizado em', ultima,
                            Icons.update, Colors.deepOrange,
                            valueFontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              _acaoPrincipal(),
              const SizedBox(height: 12),
              _acaoSecundaria(stats.total),
              const SizedBox(height: 24),
            ],
          ),
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Center(child: content),
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      {bool big = false, double? valueFontSize}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueFontSize ?? (big ? 40 : 28),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _acaoPrincipal() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _abrirNovaDfd,
        icon: const Icon(Icons.add),
        label: const Text('Nova DFD'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _acaoSecundaria(int total) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _abrirIndice,
        icon: const Icon(Icons.list_alt),
        label: Text(
          total > 0 ? 'Ver índice completo ($total)' : 'Ver índice completo',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}