import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stac/stac.dart';

import 'core/config/app_config.dart';
import 'core/di/app_bindings.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/stac/product_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  await Stac.initialize(
    // El vocabulario propio se registra al arrancar: es parte del binario.
    parsers: [if (config.vocabulary >= 2) const ProductCardParser()],
  );
  runApp(SduiApp(config: config));
}

class SduiApp extends StatelessWidget {
  const SduiApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SDUI Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialBinding: AppBindings(config),
      home: const HomePage(),
    );
  }
}
