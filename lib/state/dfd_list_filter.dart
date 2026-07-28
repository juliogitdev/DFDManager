import '../database/database_helper.dart';


class DfdListFilter {
  DfdListFilter._();
  static final DfdListFilter instance = DfdListFilter._();

  String texto = '';
  DateTime? dataInicio;
  DateTime? dataFim;
  DfdSort sort = DfdSort.maisRecente;

  bool get temFiltroData => dataInicio != null || dataFim != null;

  bool get ativo =>
      texto.trim().isNotEmpty || temFiltroData || sort != DfdSort.maisRecente;

  void limparDatas() {
    dataInicio = null;
    dataFim = null;
  }

  void resetarOrdenacao() => sort = DfdSort.maisRecente;

  void limparTudo() {
    texto = '';
    dataInicio = null;
    dataFim = null;
    sort = DfdSort.maisRecente;
  }
}