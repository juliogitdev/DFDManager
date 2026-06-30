import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/dfd.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  final _searchCtrl = TextEditingController();

  late Future<List<Dfd>> _dfdsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _dfdsFuture =
      _query.isEmpty ? _db.getAllDfds() : _db.searchDfds(_query);
    });
  }

  void _onSearch(String value) {
    _query = value;
    _refresh();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('DFD Manager'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormScreen()),
          );
          if (result == true) _refresh();
        },
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova DFD'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: const Color(0xFF1A237E),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por código ou justificativa...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                suffixIcon: _query.isNotEmpty
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

          // Lista
          Expanded(
            child: FutureBuilder<List<Dfd>>(
              future: _dfdsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'Nenhuma DFD cadastrada ainda.'
                              : 'Nenhum resultado para "$_query".',
                          style: const TextStyle(color: Colors.grey),
                        ),
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
                          backgroundColor: const Color(0xFF1A237E),
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
                            Text('Data DFD: ${dfd.dataDfd}',
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