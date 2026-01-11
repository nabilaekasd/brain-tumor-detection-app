import 'dart:convert';
import 'dart:typed_data';
import 'package:axon_vision/models/patient_model.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class RadiologController extends GetxController {
  final box = GetStorage();

  // --- 1. NAVIGASI & STATE MENU ---
  var activeIndex = 0.obs; // 0: Dashboard, 1: Data Pasien, 2: Profil
  var isDetailView = false.obs; // Apakah sedang buka detail pasien?

  // --- 2. DATA UTAMA ---
  var isLoading = false.obs;
  var dashboardSummary =
      {"total_pasien": 0, "total_menunggu": 0, "total_selesai": 0}.obs;

  var allPatientList = <PatientModel>[].obs; // Data Pasien dari Admin
  var riwayatScanList = <dynamic>[].obs; // Semua Riwayat

  // --- 3. DATA DETAIL PASIEN ---
  // Pasien yang sedang dipilih untuk dilihat detailnya
  var selectedPatient = Rxn<PatientModel>();

  // Riwayat khusus pasien yang dipilih (Filter dari riwayatScanList)
  List<dynamic> get selectedPatientHistory {
    if (selectedPatient.value == null) return [];
    return riwayatScanList.where((scan) {
      // Pastikan backend kirim 'id_rm' atau 'nama_pasien' di endpoint riwayat
      return scan['id_rm'] == selectedPatient.value!.idPasienRs;
    }).toList();
  }

  // --- 4. FORM UPLOAD ---
  TextEditingController namaPasienC = TextEditingController();
  TextEditingController idRmC = TextEditingController();
  TextEditingController tglLahirC = TextEditingController();
  TextEditingController catatanC = TextEditingController();

  var selectedGender = "Laki-laki".obs;
  var selectedStatus = "Aktif".obs;
  var selectedJenisMRI = "T1 Weighted".obs;

  var selectedFile = Rxn<PlatformFile>();
  var selectedFileName = "".obs;

  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  void refreshAllData() {
    fetchDashboardSummary();
    fetchPatients(); // Ambil data pasien
    fetchRiwayat(); // Ambil data riwayat
  }

  String? getToken() {
    return box.read('token');
  }

  // --- LOGIKA NAVIGASI ---
  void changeMenu(int index) {
    activeIndex.value = index;
    isDetailView.value = false; // Reset detail view kalau ganti menu
    selectedPatient.value = null;
  }

  void openPatientDetail(PatientModel patient) {
    selectedPatient.value = patient;
    isDetailView.value = true;

    // Otomatis isi form upload dengan data pasien ini
    namaPasienC.text = patient.nama;
    idRmC.text = patient.idPasienRs;
    tglLahirC.text = patient.tanggalLahir;
    selectedGender.value = patient.jenisKelamin;
    selectedStatus.value = patient.statusPasien;
  }

  void backToPatientList() {
    isDetailView.value = false;
    selectedPatient.value = null;
    clearForm();
  }

  // --- API CALLS ---

  // 1. Fetch Dashboard
  Future<void> fetchDashboardSummary() async {
    try {
      String? token = getToken();
      if (token == null) return;
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard-summary/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        dashboardSummary.value = {
          "total_pasien": data['total_pasien'],
          "total_menunggu": data['total_menunggu'],
          "total_selesai": data['total_selesai'],
        };
      }
    } catch (e) {
      print("Error summary: $e");
    }
  }

  // 2. Fetch Data Pasien (Sama seperti Admin)
  Future<void> fetchPatients() async {
    try {
      isLoading.value = true;
      String? token = getToken();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/patients/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var data = jsonResponse.map((e) => PatientModel.fromJson(e)).toList();
        allPatientList.assignAll(data);
      }
    } catch (e) {
      print("Error fetch patients: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Fetch Riwayat
  Future<void> fetchRiwayat() async {
    try {
      String? token = getToken();
      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/riwayat-semua/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        riwayatScanList.value = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetch riwayat: $e");
    }
  }

  // 4. Pick File (Khusus Web Desktop & Web)
  Future<void> pickMRIFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      selectedFile.value = result.files.first;
      selectedFileName.value = result.files.first.name;
    }
  }

  // 5. Upload MRI
  Future<void> uploadAndAnalyze() async {
    if (selectedFile.value == null) {
      Get.snackbar("Error", "File MRI belum dipilih!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    // Data pasien sudah otomatis terisi dari fungsi openPatientDetail

    try {
      isLoading.value = true;
      String? token = getToken();

      var uri = Uri.parse('${ApiConfig.baseUrl}/upload-mri/');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nama'] = namaPasienC.text;
      request.fields['id_pasien'] = idRmC.text;
      request.fields['tgl_lahir'] = tglLahirC.text;
      request.fields['status'] = selectedStatus.value;
      request.fields['jenis_mri'] = selectedJenisMRI.value;
      request.fields['catatan'] = catatanC.text.isEmpty ? "-" : catatanC.text;

      // Handle File Upload (Bytes for Web/Desktop Web)
      if (selectedFile.value!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          selectedFile.value!.bytes!,
          filename: selectedFile.value!.name,
        ));
      } else if (selectedFile.value!.path != null) {
        // Fallback untuk native desktop app (bukan web)
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          selectedFile.value!.path!,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var hasilAI = data['hasil_ai'];

        Get.defaultDialog(
            title: "Hasil Analisis Selesai",
            middleText: "Prediksi AI: $hasilAI",
            textConfirm: "Tutup",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              fetchRiwayat(); // Refresh data riwayat di bawah
              fetchDashboardSummary();

              // Reset input file tapi biarkan data pasien
              selectedFile.value = null;
              selectedFileName.value = "";
              catatanC.clear();
            });
      } else {
        Get.snackbar("Gagal", "Error: ${response.body}");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Gagal koneksi server");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    namaPasienC.clear();
    idRmC.clear();
    tglLahirC.clear();
    catatanC.clear();
    selectedFile.value = null;
    selectedFileName.value = "";
  }
}
