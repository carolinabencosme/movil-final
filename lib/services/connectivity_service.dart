import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Service that observes connectivity changes and confirms actual internet
/// reachability with a lightweight network probe.
class ConnectivityService {
  ConnectivityService._() {
    _subscription = _connectivity.onConnectivityChanged
        .listen(_handleConnectivityChange, onError: (_) {});
    _initialize();
  }

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _offlineController =
      StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOffline = false;

  /// Stream that emits the current offline state. The value only flips to
  /// online after a successful reachability probe.
  Stream<bool> get isOfflineStream => _offlineController.stream;

  /// Latest offline state value.
  bool get isOffline => _isOffline;

  Future<void> _initialize() async {
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(results);
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final bool hasNetwork =
        results.any((ConnectivityResult result) => result != ConnectivityResult.none);
    if (!hasNetwork) {
      _updateOfflineState(true);
      return;
    }

    final bool reachable = await _probeReachability();
    _updateOfflineState(!reachable);
  }

  Future<bool> _probeReachability() async {
    try {
      final uri = Uri.parse('https://pokeapi.co/');
      final response = await http
          .head(uri)
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return true;
      }

      final fallbackResponse =
          await http.get(uri).timeout(const Duration(seconds: 3));
      return fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  void _updateOfflineState(bool offline) {
    if (_isOffline == offline) {
      return;
    }
    _isOffline = offline;
    _offlineController.add(_isOffline);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _offlineController.close();
  }
}
