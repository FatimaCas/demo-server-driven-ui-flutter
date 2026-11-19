import 'store_db.dart';

/// Primera versión de la app que sabe dibujar el widget `productCard`.
const productCardSince = 2;

/// Arma la pantalla `home` en formato Stac con lo que hay en la base.
///
/// [clientVersion] es la versión del *vocabulario* de la app (header
/// `x-client-version`): qué widgets trae compilados. El JSON solo puede
/// componer con ese vocabulario, así que a una app vieja se le manda la
/// misma tarjeta armada con widgets básicos de Stac.
Map<String, dynamic> buildHome(
  StoreDb db, {
  required int clientVersion,
}) {
  final blackFriday = db.blackFriday;
  final products = db.featuredProducts();
  final useProductCard = clientVersion >= productCardSince;

  return {
    'name': 'home',
    'title': blackFriday ? 'SDUI Store · Black Friday' : 'SDUI Store',
    'layout': {
      'type': 'column',
      'crossAxisAlignment': 'stretch',
      'children': [
        _banner(blackFriday),
        _sectionTitle(blackFriday ? 'Ofertas relámpago' : 'Destacados'),
        {
          'type': 'gridView',
          'shrinkWrap': true,
          'physics': 'never',
          'crossAxisCount': 2,
          'mainAxisSpacing': 12,
          'crossAxisSpacing': 12,
          'childAspectRatio': 0.8,
          'padding': [16, 0, 16, 16],
          'children': [
            for (final p in products)
              useProductCard
                  ? _productCard(p, blackFriday)
                  : _basicCard(p, blackFriday),
          ],
        },
      ],
    },
  };
}

String formatPrice(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }
  return '\$ $out';
}

Map<String, dynamic> _banner(bool blackFriday) => {
      'type': 'container',
      'margin': 16,
      'padding': 20,
      'decoration': {
        'color': blackFriday ? '#111111' : '#3F51B5',
        'borderRadius': 16,
      },
      'child': {
        'type': 'column',
        'crossAxisAlignment': 'start',
        'spacing': 6,
        'children': [
          {
            'type': 'text',
            'data': blackFriday ? 'BLACK FRIDAY' : 'Ofertas de la semana',
            'style': {
              'fontSize': 22,
              'fontWeight': 'w700',
              'color': blackFriday ? '#FF9800' : '#FFFFFF',
            },
          },
          {
            'type': 'text',
            'data': blackFriday
                ? 'Hasta 50% en toda la tienda'
                : 'Hasta 30% en tecnología',
            'style': {
              'fontSize': 14,
              'color': blackFriday ? '#FFFFFF' : '#E8EAF6',
            },
          },
        ],
      },
    };

Map<String, dynamic> _sectionTitle(String text) => {
      'type': 'padding',
      'padding': [16, 8, 16, 8],
      'child': {
        'type': 'text',
        'data': text,
        'style': {'fontSize': 18, 'fontWeight': 'w600'},
      },
    };

/// Widget propio: la app lo registró con su parser (ver `product_card.dart`).
Map<String, dynamic> _productCard(Product p, bool blackFriday) => {
      'type': 'productCard',
      'name': p.name,
      'icon': p.icon,
      'price': formatPrice(p.price),
      if (blackFriday && p.oldPrice != null) 'oldPrice': formatPrice(p.oldPrice!),
    };

/// La misma tarjeta, solo con widgets que Stac trae de fábrica.
Map<String, dynamic> _basicCard(Product p, bool blackFriday) => {
      'type': 'card',
      'child': {
        'type': 'padding',
        'padding': 12,
        'child': {
          'type': 'column',
          'crossAxisAlignment': 'start',
          'spacing': 6,
          'children': [
            {'type': 'icon', 'icon': p.icon, 'size': 40, 'color': '#3F51B5'},
            {
              'type': 'text',
              'data': p.name,
              'style': {'fontWeight': 'w600'},
            },
            {'type': 'text', 'data': formatPrice(p.price)},
          ],
        },
      },
    };
