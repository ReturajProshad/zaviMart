import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zavimart/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    if (!kDebugMode) {
      debugPrint('Error: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    } else {
      FlutterError.presentError(details);
    }
  };

  runApp(const ZaviMartApp());
}
