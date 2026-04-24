// Classe base para falhas
abstract class Failure {
  final String message;

  Failure(this.message);
}

// Exemplo de falha específica
class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}
