import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stac/stac.dart';

import '../viewmodels/home_view_model.dart';

/// El "cascarón" nativo: AppBar, pull-to-refresh y estados de carga/error.
/// Todo lo que está dentro del scroll lo decide el servidor.
class HomePage extends GetView<HomeViewModel> {
  const HomePage({super.key});

  static const refreshButtonKey = Key('home.refresh');
  static const errorKey = Key('home.error');
  static const contentKey = Key('home.content');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.screen.value?.title ?? 'SDUI Store')),
        actions: [
          IconButton(
            key: refreshButtonKey,
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: controller.load,
          ),
        ],
      ),
      body: Obx(() {
        final screen = controller.screen.value;
        final error = controller.error.value;

        if (screen == null && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (screen == null) {
          return _ErrorView(message: error ?? '', onRetry: controller.load);
        }

        return RefreshIndicator(
          onRefresh: controller.load,
          child: SingleChildScrollView(
            key: contentKey,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) _ErrorBanner(message: error),
                Stac.fromJson(screen.layout, context) ?? const SizedBox(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: HomePage.errorKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Se muestra encima de la última pantalla buena cuando una recarga falla.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.errorContainer,
      padding: const EdgeInsets.all(12),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}
