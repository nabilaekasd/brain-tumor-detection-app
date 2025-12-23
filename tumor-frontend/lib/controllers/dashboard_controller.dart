import 'dart:developer';

import 'package:axon_vision/models/data_analisis_model.dart';
import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/table_source/analisis_data_source.dart';
import 'package:axon_vision/table_source/pasien_data_source.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  List<DataPasienModel> pasienData = <DataPasienModel>[];
  List<DataAnalisisModel> analisisData = <DataAnalisisModel>[];
  List<DataPasienModel> originalPasienData = <DataPasienModel>[];

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
    pasienData = getPasienData();
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
    pasienData = filtered;
    refreshPasienDataSource();
  }

  double getPasienPageCount() {
    if (pasienData.isEmpty) return 1;
    return (analisisData.length / pageSize).ceilToDouble();
  }

  double getAnalisisPageCount() {
    return (analisisData.length / pageSize).ceilToDouble();
  }

  //Dummy Data
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

  //Dummy Data
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
