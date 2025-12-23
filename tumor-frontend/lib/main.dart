import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan import ini ada
import 'package:axon_vision/pages/login/login_page.dart'; // Sesuaikan path login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Axon Vision',

      theme: ThemeData(
        useMaterial3: true,

        // 1. SETTING FONT GLOBAL
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        // 2. PAKSA BACKGROUND PUTIH BERSIH
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white, // Untuk Dropdown lama
        cardColor: Colors.white,

        // 3. HILANGKAN EFEK TINT (BAYANGAN WARNA) PADA POPUP & DIALOG
        // Ini kuncinya agar tidak ada warna ungu/biru tipis
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        // Untuk Dropdown Menu
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          ),
        ),
      ),

      home: const LoginPage(),
    );
  }
}
