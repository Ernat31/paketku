
import 'package:flutter_test/flutter_test.dart';
import 'package:paketku/main.dart';

void main() {
  testWidgets('Beranda PaketKu tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const PaketKuApp());

    expect(find.text('PaketKu'), findsOneWidget);
    expect(find.text('Paket Aktif'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
