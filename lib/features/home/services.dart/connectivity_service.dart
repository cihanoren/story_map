import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = ChangeNotifierProvider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

class ConnectivityService extends ChangeNotifier {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final disconnected = result == ConnectivityResult.none;

      if (_isOffline != disconnected) {
        _isOffline = disconnected;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
