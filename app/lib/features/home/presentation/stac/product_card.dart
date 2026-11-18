import 'package:flutter/material.dart';
import 'package:stac/stac.dart';

/// Lo que el servidor manda para una tarjeta de producto:
///
/// ```json
/// { "type": "productCard", "name": "Audífonos BT", "icon": "headphones",
///   "price": "$ 200.900", "oldPrice": "$ 299.900" }
/// ```
class ProductCardModel {
  const ProductCardModel({
    required this.name,
    required this.price,
    required this.icon,
    this.oldPrice,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> json) {
    return ProductCardModel(
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '',
      icon: json['icon'] as String? ?? 'shopping_bag',
      oldPrice: json['oldPrice'] as String?,
    );
  }

  final String name;
  final String price;
  final String icon;
  final String? oldPrice;
}

/// Parser de Stac para `productCard`: convierte el modelo en un widget.
///
/// Es vocabulario nuevo para el JSON, pero viaja *compilado* en la app:
/// una versión que no lo registró no sabe dibujarlo.
class ProductCardParser extends StacParser<ProductCardModel> {
  const ProductCardParser();

  @override
  String get type => 'productCard';

  @override
  ProductCardModel getModel(Map<String, dynamic> json) =>
      ProductCardModel.fromJson(json);

  @override
  Widget parse(BuildContext context, ProductCardModel model) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Stac.fromJson({
                      'type': 'icon',
                      'icon': model.icon,
                      'size': 48,
                      'color': '#3F51B5',
                    }, context) ??
                    const SizedBox(),
              ),
            ),
            Text(
              model.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            if (model.oldPrice != null)
              Text(
                model.oldPrice!,
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.outline,
                ),
              ),
            Text(
              model.price,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: model.oldPrice != null ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
