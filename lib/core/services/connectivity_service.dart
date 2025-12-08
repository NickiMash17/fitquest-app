import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// Service for monitoring network connectivity
@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  
  StreamController<ConnectivityResult>? _connectivityController;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService() {
    _connectivityController = StreamController<ConnectivityResult>.broadcast();
    _startMonitoring();
  }

  /// Get current connectivity status
  Future<ConnectivityResult> getCurrentStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result;
    } catch (e) {
      _logger.w('Error checking connectivity: $e');
      return ConnectivityResult.none;
    }
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivityController!.stream;
  }

  /// Check if device is currently online
  Future<bool> isOnline() async {
    final status = await getCurrentStatus();
    return status != ConnectivityResult.none;
  }

  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _logger.d('Connectivity changed: $result');
        _connectivityController?.add(result);
      },
      onError: (error) {
        _logger.e('Connectivity monitoring error: $error');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
  }
}

