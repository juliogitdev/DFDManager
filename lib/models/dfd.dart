class Dfd {
  final int? id;
  final String codigo;
  final String dataDfd;       // Data registrada na DFD oficial
  final String dataCriacao;   // Data que registrou no app
  final String justificativa;

  Dfd({
    this.id,
    required this.codigo,
    required this.dataDfd,
    required this.dataCriacao,
    required this.justificativa,
  });

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
}