import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stac/stac.dart';

import 'core/config/app_config.dart';
import 'core/di/app_bindings.dart';
import 'features/home/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Stac.initialize();
  runApp(SduiApp(config: AppConfig.fromEnvironment()));
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
