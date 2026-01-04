import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      final isConnected = result != ConnectivityResult.none;
      _connectivityController?.add(isConnected);
    });
  }

  /// Check current connectivity status
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController?.close();
  }
}
