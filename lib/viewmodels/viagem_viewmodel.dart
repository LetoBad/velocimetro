import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:velocimetro/models/viagem_model.dart';

// ViewModel responsável por gerenciar os dados da viagem (distância, velocidade, etc.)
class TripViewModel with ChangeNotifier {
  ViagemModel _tripData = ViagemModel(); // Armazena os dados da viagem
  StreamSubscription<Position>? _positionStreamSubscription; // Stream para escutar posições do GPS
  Position? _lastPosition; // Última posição registrada
  DateTime? _startTime; // Horário em que a viagem começou
  DateTime? _lastUpdateTime; // Último horário de atualização dos dados

  // Getters para acessar os dados do modelo externamente
  double get currentSpeed => _tripData.currentSpeed;
  double get distance => _tripData.distance;
  double get averageSpeed => _tripData.averageSpeed;
  Duration get tripDuration => _tripData.tripDuration;

  // Estado do rastreamento
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // Estado da permissão de localização
  bool _hasLocationPermission = false;
  bool get hasLocationPermission => _hasLocationPermission;

  // Inicialização do ViewModel: verifica permissão
  Future<void> init() async {
    await _checkLocationPermission();
  }

  // Verifica se o app tem permissão de localização e se o GPS tá ativado
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _hasLocationPermission = false;
      notifyListeners();
      return;
    }

    // Verifica e solicita permissão se necessário
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _hasLocationPermission = false;
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissão negada permanentemente
      _hasLocationPermission = false;
      notifyListeners();
      return;
    }

    _hasLocationPermission = true;
    notifyListeners(); // Notifica que a permissão foi atualizada
  }

  // Método público para solicitar permissão de localização
  Future<void> requestLocationPermission() async {
    await _checkLocationPermission();
  }

  // Inicia o rastreamento da viagem
  void startTracking() {
    if (!_hasLocationPermission || _isTracking) return;

    _isTracking = true;
    _startTime = DateTime.now();
    _lastUpdateTime = _startTime;

    // Configuração da precisão e frequência de atualização da localização
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Atualiza a cada 5 metros
    );

    // Inicia escuta do stream de posições
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateTripData(position); // Atualiza os dados da viagem a cada nova posição
    });

    notifyListeners();
  }

  // Pausa o rastreamento
  void pauseTracking() {
    if (!_isTracking) return;

    _positionStreamSubscription?.pause();
    _isTracking = false;
    notifyListeners();
  }

  // Retoma o rastreamento se estiver pausado
  void resumeTracking() {
    if (_isTracking) return;

    _positionStreamSubscription?.resume();
    _lastUpdateTime = DateTime.now();
    _isTracking = true;
    notifyListeners();
  }

  // Reinicia os dados da viagem (zera tudo)
  void resetTracking() {
    _tripData = ViagemModel();
    _lastPosition = null;
    _startTime = _isTracking ? DateTime.now() : null;
    _lastUpdateTime = _startTime;
    notifyListeners();
  }

  // Atualiza os dados da viagem com base na nova posição
  void _updateTripData(Position position) {
    final now = DateTime.now();

    // Converte velocidade de m/s para km/h
    double speedKmh = position.speed * 3.6;

    // Se já tem uma posição anterior, calcula a distância entre elas
    if (_lastPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Atualiza a distância total (em km)
      _tripData = _tripData.copyWith(
        distance: _tripData.distance + (distanceInMeters / 1000),
      );
    }

    // Atualiza a duração da viagem
    if (_startTime != null) {
      _tripData = _tripData.copyWith(
        tripDuration: now.difference(_startTime!),
      );
    }

    // Calcula a velocidade média com base no tempo e distância
    if (_tripData.tripDuration.inSeconds > 0) {
      double avgSpeed = (_tripData.distance / _tripData.tripDuration.inSeconds) * 3600;
      _tripData = _tripData.copyWith(averageSpeed: avgSpeed);
    }

    // Atualiza a velocidade atual
    _tripData = _tripData.copyWith(currentSpeed: speedKmh);

    _lastPosition = position;
    _lastUpdateTime = now;

    notifyListeners(); // Notifica os listeners que os dados mudaram
  }

  // Cancela a escuta do stream ao destruir o ViewModel
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
