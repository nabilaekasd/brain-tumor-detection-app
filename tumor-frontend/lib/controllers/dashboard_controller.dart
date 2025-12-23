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
    pasienDataSource = PasienDataSource(
      dataPasien: pasienData,
      userRole: userRole,
      onUploadTap: handledChangeScreenDynamic,
      onDetailTap: (pasien) {
        log("Dokter melihat: ${pasien.namePatient}");
      },
    );
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

  // Method update status filter
  void updateStatusFilter(String status) {
    selectedStatusFilter = status;
    searchPatients(searchController.text);
  }

  // Method untuk mencari pasien
  void searchPatients(String query) {
    isSearching.value = true;

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

    pasienDataSource = PasienDataSource(
      dataPasien: pasienData,
      userRole: userRole,
      onUploadTap: handledChangeScreenDynamic,
      onDetailTap: (pasien) {
        log("Detail filter: ${pasien.namePatient}");
      },
    );

    update();
  }

  double getPasienPageCount() {
    return (pasienData.length / pageSize).ceilToDouble();
  }

  double getAnalisisPageCount() {
    return (analisisData.length / pageSize).ceilToDouble();
  }

  //Dummy Data
  List<DataPasienModel> getPasienData() {
    return [
      DataPasienModel(
        idPatient: 'P001',
        namePatient: 'Abdul',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P002',
        namePatient: 'Togar',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P003',
        namePatient: 'Siti',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P004',
        namePatient: 'Dewi',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P005',
        namePatient: 'Hidayat',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P006',
        namePatient: 'Oyen',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P007',
        namePatient: 'Santoso',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P008',
        namePatient: 'Santoso',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Tidak Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P009',
        namePatient: 'Santoso',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P0010',
        namePatient: 'Santoso',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
      DataPasienModel(
        idPatient: 'P0011',
        namePatient: 'Santoso',
        tanggalLahir: 'DD/MM/YYYY',
        status: 'Aktif',
        action: 'icon',
      ),
    ];
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
        estimasi: '30 Menit',
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
