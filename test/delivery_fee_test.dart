import 'package:flutter_test/flutter_test.dart';

import 'package:tangcal_batanes/backend/order_service.dart';

DeliveryArea area(String barangay) =>
    kDeliveryAreas.firstWhere((a) => a.barangay == barangay);

void main() {
  test('Basco is a flat ₱50', () {
    for (final a in kDeliveryAreas.where((a) => a.town == 'Basco')) {
      expect(a.fee, 50.0, reason: a.label);
    }
  });

  test('outside Basco adds ₱5 per road km, partial km rounded up', () {
    expect(area('Kaumbakan').fee, 85.0); // 6.6 km -> 7
    expect(area('Hañib').fee, 95.0); // 8.4 km -> 9
    expect(area('Tuhel (Poblacion)').fee, 130.0); // 15.7 km -> 16
    expect(area('Kayvaluganan (Poblacion)').fee, 160.0); // 21.4 km -> 22
    expect(area('Hañib').feeBreakdown, '₱50.00 + 9 km × ₱5.00');
  });

  test('guesses the area from a saved address only when unambiguous', () {
    expect(guessDeliveryArea('Purok 2, Hanib, Mahatao')?.barangay, 'Hañib');
    expect(guessDeliveryArea('Kayvaluganan, Uyugan')?.town, 'Uyugan');
    expect(guessDeliveryArea('Kayvaluganan, Basco')?.barangay,
        'Ihubok II (Kayvaluganan)');
    expect(guessDeliveryArea('Kayvaluganan'), isNull);
    expect(guessDeliveryArea('Ihubok II, Basco')?.barangay,
        'Ihubok II (Kayvaluganan)');
    expect(guessDeliveryArea('Ihubok I, Basco')?.barangay,
        'Ihubok I (Kaychanarianan)');
    expect(guessDeliveryArea('Somewhere else'), isNull);
  });
}
