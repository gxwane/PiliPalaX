import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persisted theme indexes keep their enum meaning', () {
    expect(
      FlexSchemeVariant.values.map((variant) => variant.name).toList(),
      <String>[
        'tonalSpot',
        'fidelity',
        'monochrome',
        'neutral',
        'vibrant',
        'expressive',
        'content',
        'rainbow',
        'fruitSalad',
        'material',
        'material3Legacy',
        'soft',
        'vivid',
        'vividSurfaces',
        'highContrast',
        'ultraContrast',
        'jolly',
        'vividBackground',
        'oneHue',
        'candyPop',
        'chroma',
      ],
    );
    expect(FlexSchemeVariant.values[10], FlexSchemeVariant.material3Legacy);
  });
}
