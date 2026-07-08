import 'package:intl/intl.dart';

class Dfd {
  final int? id;
  final String codigo;
  final String dataDfd;
  final String dataCriacao;
  final String justificativa;

  static final _isoFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('dd/MM/yyyy');

  Dfd({
    this.id,
    required this.codigo,
    required this.dataDfd,
    required this.dataCriacao,
    required this.justificativa,
  });

  String get dataDfdFormatada {
    try {
      return _displayFormat.format(_isoFormat.parse(dataDfd));
    } catch (_) {
      return dataDfd; // Fallback para dados legados
    }
  }

  String get dataCriacaoFormatada {
    try {
      return _displayFormat.format(_isoFormat.parse(dataCriacao));
    } catch (_) {
      return dataCriacao;
    }
  }

  static String dateToIso(DateTime date) => _isoFormat.format(date);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'dataDfd': dataDfd,
      'dataCriacao': dataCriacao,
      'justificativa': justificativa,
    };
  }

  factory Dfd.fromMap(Map<String, dynamic> map) {
    return Dfd(
      id: map['id'],
      codigo: map['codigo'],
      dataDfd: map['dataDfd'],
      dataCriacao: map['dataCriacao'],
      justificativa: map['justificativa'],
    );
  }

  Dfd copyWith({
    int? id,
    String? codigo,
    String? dataDfd,
    String? dataCriacao,
    String? justificativa,
  }) {
    return Dfd(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      dataDfd: dataDfd ?? this.dataDfd,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      justificativa: justificativa ?? this.justificativa,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Dfd && other.id == id;

  @override
  int get hashCode => id.hashCode;
}