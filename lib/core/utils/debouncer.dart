import 'dart:async';

/// Debouncer utility for delaying function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler utility for limiting function call frequency
class Throttler {
  final Duration delay;
  DateTime? _lastCall;
  Timer? _timer;

  Throttler({this.delay = const Duration(milliseconds: 300)});

  void call(void Function() callback) {
    final now = DateTime.now();
    
    if (_lastCall == null || 
        now.difference(_lastCall!) >= delay) {
      _lastCall = now;
      callback();
    } else {
      _timer?.cancel();
      _timer = Timer(
        delay - now.difference(_lastCall!),
        () {
          _lastCall = DateTime.now();
          callback();
        },
      );
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lastCall = null;
  }
}


