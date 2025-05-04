// Modelo de dados que representa uma viagem
class ViagemModel {
  double currentSpeed; // Velocidade atual em km/h
  double distance; // Distância total percorrida em km
  double averageSpeed; // Velocidade média da viagem em km/h
  Duration tripDuration; // Duração total da viagem

  // Construtor com valores padrão
  ViagemModel({
    this.currentSpeed = 0.0,   // Inicializa a velocidade atual como 0
    this.distance = 0.0,       // Inicializa a distância percorrida como 0
    this.averageSpeed = 0.0,   // Inicializa a velocidade média como 0
    this.tripDuration = const Duration(), // Inicializa a duração como zero
  });

  // Método para copiar o modelo e atualizar apenas os campos desejados
  ViagemModel copyWith({
    double? currentSpeed,   // Novo valor opcional para velocidade atual
    double? distance,       // Novo valor opcional para distância
    double? averageSpeed,   // Novo valor opcional para velocidade média
    Duration? tripDuration, // Novo valor opcional para duração da viagem
  }) {
    // Retorna uma nova instância de ViagemModel com os valores atualizados
    return ViagemModel(
      currentSpeed: currentSpeed ?? this.currentSpeed,
      distance: distance ?? this.distance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      tripDuration: tripDuration ?? this.tripDuration,
    );
  }
}
