import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/routes/app_routes.dart';

class ZaviMartApp extends ConsumerStatefulWidget {
  const ZaviMartApp({super.key});

  @override
  ConsumerState<ZaviMartApp> createState() => _ZaviMartAppState();
}

class _ZaviMartAppState extends ConsumerState<ZaviMartApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'ZaviMart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: router,
      ),
    );
  }
}
