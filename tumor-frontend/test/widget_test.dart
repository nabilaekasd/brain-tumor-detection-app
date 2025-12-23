import 'package:flutter_test/flutter_test.dart';
import 'package:axon_vision/main.dart'; // Pastikan import ini mengarah ke file main.dart Anda

void main() {
  testWidgets('Login Page smoke test', (WidgetTester tester) async {
    // 1. Build aplikasi Anda (Gunakan MyApp, bukan AxonVision)
    await tester.pumpWidget(const MyApp());

    // Tunggu animasi atau frame render selesai (penting untuk GetX/Animations)
    await tester.pumpAndSettle();

    // 2. Cek apakah halaman Login muncul
    // Kita cari teks 'Login' atau 'Sistem Deteksi' yang pasti ada di halaman login
    // findsWidgets artinya menemukan setidaknya satu (bisa tombol login, atau judul)
    expect(find.textContaining('Login'), findsWidgets);

    // Pastikan TIDAK ada angka '0' (Sisa kode template lama)
    expect(find.text('0'), findsNothing);
  });
}
