import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      child: MaterialApp(
        title: 'ZaviMart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(body: Center(child: Text("Initial page"))),
      ),
    );
  }
}
