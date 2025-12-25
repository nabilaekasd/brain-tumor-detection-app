import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:axon_vision/models/data_analisis_model.dart';
import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/table_source/analisis_data_source.dart';
import 'package:axon_vision/table_source/pasien_data_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- MODEL KHUSUS RIWAYAT ---
class RiwayatModel {
  final String jenisMri;
  final String tanggal;
  final String hasil;

  RiwayatModel({
    required this.jenisMri,
    required this.tanggal,
    required this.hasil,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    return RiwayatModel(
      jenisMri: json['jenis_mri'] ?? 'MRI Scan',
      tanggal: json['tanggal_periksa'] ?? '-',
      hasil: json['hasil_prediksi'] ?? 'Belum Dianalisis',
    );
  }
}

class DashboardController extends GetxController {
  // --- PERBAIKAN DI SINI: UBAH JADI .OBS ---
  var pasienData = <DataPasienModel>[].obs; // Sekarang jadi Reactive

  List<DataAnalisisModel> analisisData = <DataAnalisisModel>[];
  List<DataPasienModel> originalPasienData = <DataPasienModel>[];

  // --- VARIABLE DATA DARI BACKEND ---
  var riwayatList = <RiwayatModel>[].obs;

  // --- VARIABLE STATISTIK (DASHBOARD SUMMARY) ---
  var totalPasien = 0.obs;
  var totalMenunggu = 0.obs;
  var totalSelesai = 0.obs;

  TextEditingController searchController = TextEditingController();
  late PasienDataSource pasienDataSource;
  late PasienDataSource homePasienDataSource;
  late AnalisisDataSource analisisDataSource;

  final RxBool isSearching = RxBool(false);
  final int pageSize = 10;
  final RxInt currentPage = 1.obs;
  final RxInt _activeMenuIndex = 0.obs;
  final RxBool isSidebarExpanded = true.obs;
  final String userRole = 'radiolog';
  String selectedStatusFilter = 'Semua Status';
  final RxInt changeTextMenu = RxInt(0);
  final Rx<DataPasienModel?> _selectedPasien = Rx<DataPasienModel?>(null);

  int get activeMenuIndex => _activeMenuIndex.value;
  DataPasienModel? get selectedPasien => _selectedPasien.value;

  @override
  void onInit() {
    super.onInit();
    // PERBAIKAN: Gunakan assignAll karena sekarang dia .obs
    pasienData.assignAll(getPasienData());

    analisisData = getAnalisisData();
    analisisDataSource = AnalisisDataSource(analisisData);
    originalPasienData = List.from(pasienData);
    refreshPasienDataSource();
    homePasienDataSource = PasienDataSource(
      dataPasien: pasienData.take(5).toList(),
      userRole: userRole,
      onUploadTap: handledChangeScreenDynamic,
      onDetailTap: (pasien) {
        log("Dokter melihat home: ${pasien.namePatient}");
      },
    );

    // --- PANGGIL DATA DARI BACKEND ---
    fetchRiwayat();
    fetchSummary();
  }

  // --- FUNGSI 1: AMBIL RIWAYAT (LIST) ---
  void fetchRiwayat() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/riwayat-semua/');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var data = jsonResponse
            .map((job) => RiwayatModel.fromJson(job))
            .toList();

        riwayatList.assignAll(data.reversed.toList());
        log("BERHASIL AMBIL ${data.length} DATA RIWAYAT!", name: 'API RIWAYAT');
      } else {
        log('Gagal ambil riwayat: ${response.statusCode}');
      }
    } catch (e) {
      log('Error koneksi backend (Riwayat): $e');
    }
  }

  // --- FUNGSI 2: AMBIL STATISTIK (ANGKA X, Y, Z) ---
  void fetchSummary() async {
    try {
      var url = Uri.parse('http://127.0.0.1:8000/dashboard-summary/');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        totalPasien.value = data['total_pasien'] ?? 0;
        totalMenunggu.value = data['total_menunggu'] ?? 0;
        totalSelesai.value = data['total_selesai'] ?? 0;

        log("BERHASIL UPDATE SUMMARY: $data", name: 'API SUMMARY');
      } else {
        log('Gagal ambil summary: ${response.statusCode}');
      }
    } catch (e) {
      log('Error koneksi backend (Summary): $e');
    }
  }

  void toggleSidebar() {
    isSidebarExpanded.toggle();
    update();
  }

  void handledChangeScreenDynamic(DataPasienModel pasien) {
    _selectedPasien.value = pasien;
    _activeMenuIndex.value = 2;
    update();
  }

  void changeMenu(int index) {
    _activeMenuIndex.value = index;
    log("Menu changed to: $index");
    update();

    if (index == 0) {
      fetchSummary();
    }
    if (index == 2 || index == 4) {
      fetchRiwayat();
    }
  }

  void backToPasienList() {
    _activeMenuIndex.value = 1;
    _selectedPasien.value = null;
    update();
  }

  List<DataPasienModel> get _currentPaginatedData {
    int start = (currentPage.value - 1) * pageSize;
    int end = start + pageSize;

    if (end > pasienData.length) end = pasienData.length;
    if (start >= pasienData.length) return [];
    return pasienData.sublist(start, end);
  }

  void refreshPasienDataSource() {
    pasienDataSource = PasienDataSource(
      dataPasien: _currentPaginatedData,
      userRole: userRole,
      onUploadTap: handledChangeScreenDynamic,
      onDetailTap: (pasien) {
        log("Dokter melihat: ${pasien.namePatient}");
      },
    );
    update();
  }

  void nextPage() {
    if (currentPage.value < getPasienPageCount()) {
      currentPage.value++;
      refreshPasienDataSource();
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      refreshPasienDataSource();
    }
  }

  void updateStatusFilter(String status) {
    selectedStatusFilter = status;
    searchPatients(searchController.text);
  }

  void searchPatients(String query) {
    isSearching.value = true;
    currentPage.value = 1;

    List<DataPasienModel> filtered = List.from(originalPasienData);
    if (selectedStatusFilter != 'Semua Status') {
      filtered = filtered
          .where(
            (patient) =>
                patient.status.toLowerCase() ==
                selectedStatusFilter.toLowerCase(),
          )
          .toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered.where((patient) {
        final name = patient.namePatient.toLowerCase();
        final id = patient.idPatient.toLowerCase();
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) || id.contains(searchLower);
      }).toList();
    }

    // PERBAIKAN: Gunakan assignAll
    pasienData.assignAll(filtered);
    refreshPasienDataSource();
  }

  double getPasienPageCount() {
    if (pasienData.isEmpty) return 1;
    return (analisisData.length / pageSize).ceilToDouble();
  }

  double getAnalisisPageCount() {
    return (analisisData.length / pageSize).ceilToDouble();
  }

  List<DataPasienModel> getPasienData() {
    return List.generate(25, (index) {
      int id = index + 1;
      return DataPasienModel(
        idPatient: 'P${id.toString().padLeft(3, '0')}',
        namePatient: index % 2 == 0 ? 'Dirman Santoso $id' : 'Dita Aminah $id',
        tanggalLahir: '12/05/1980',
        status: index % 3 == 0 ? 'Tidak Aktif' : 'Aktif',
        action: 'icon',
      );
    });
  }

  List<DataAnalisisModel> getAnalisisData() {
    return [
      DataAnalisisModel(
        namePatient: 'Abdul',
        tanggalScan: 'DD/MM/YYYY',
        status: 'Sedang di Analisis',
        estimasi: '30 Menit',
      ),
      DataAnalisisModel(
        namePatient: 'Joko',
        tanggalScan: 'DD/MM/YYYY',
        status: 'Menunggu',
        estimasi: '45 Menit',
      ),
      DataAnalisisModel(
        namePatient: 'Karang',
        tanggalScan: 'DD/MM/YYYY',
        status: 'Selesai',
        estimasi: '-',
      ),
    ];
  }
}
