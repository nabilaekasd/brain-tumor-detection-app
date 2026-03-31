import 'dart:convert';
import 'dart:math';
import 'package:axon_vision/models/patient_model.dart';
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // File_picker dihapus karena tidak upload MRI

class DokterController extends GetxController {
  final box = GetStorage();

  // Variabel Data
  var activeIndex = 0.obs;
  var isSidebarExpanded = true.obs;
  var patientViewStep = 0.obs; // 0: List, 1: Detail, 2: Analisis
  var detailAnalysisData = {}.obs;
  var isLoadingDetail = false.obs;
  var isLoading = false.obs;
  var selectedAnalysisId = "".obs;
  var isSortNewest = true.obs;

  // Data Profil (Default disesuaikan untuk Dokter)
  var displayName = 'Dokter'.obs;
  var displayRole = 'Doctor'.obs;
  var profileImageUrl = "".obs;
  var currentUserId = 0.obs;

  // Data Dashboard
  var dashboardSummary =
      {"total_pasien": 0, "total_menunggu": 0, "total_selesai": 0}.obs;
  var riwayatScanList = <dynamic>[].obs;
  var selectedPatient = Rxn<PatientModel>();

  // Pagination & Data Pasien
  var allPatientList = <PatientModel>[].obs;
  var filteredPatientList = <PatientModel>[].obs;
  var patientCurrentPage = 1.obs;
  var itemsPerPage = 9;

  List<PatientModel> get currentPatients {
    if (filteredPatientList.isEmpty) return [];
    int start = (patientCurrentPage.value - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    return filteredPatientList.sublist(
        start, min(end, filteredPatientList.length));
  }

  int get totalPatientPages {
    if (filteredPatientList.isEmpty) return 1;
    return (filteredPatientList.length / itemsPerPage).ceil();
  }

  List<dynamic> get selectedPatientHistory {
    if (selectedPatient.value == null) return [];
    return riwayatScanList.where((scan) {
      return scan['id_rm'] == selectedPatient.value!.idPasienRs;
    }).toList();
  }

  // FORM VARIABLES (Variabel Upload MRI sudah dihapus)
  TextEditingController myUsernameC = TextEditingController();
  TextEditingController myFullNameC = TextEditingController();
  TextEditingController oldPasswordC = TextEditingController();
  TextEditingController newPasswordC = TextEditingController();

  var isObscureOld = true.obs;
  var isObscureNew = true.obs;

  // LIFECYCLE & HELPERS
  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  void refreshAllData() {
    fetchMyProfile();
    fetchDashboardSummary();
    fetchPatients();
    fetchRiwayat();
  }

  String? getToken() {
    String? token = box.read('token');
    if (token == null) {
      Get.offAll(() => const LoginPage());
      return null;
    }
    return token;
  }

  void nextPatientPage() {
    if (patientCurrentPage.value < totalPatientPages) {
      patientCurrentPage.value++;
    }
  }

  void prevPatientPage() {
    if (patientCurrentPage.value > 1) {
      patientCurrentPage.value--;
    }
  }

  void searchPatient(String query) {
    if (query.isEmpty) {
      filteredPatientList.assignAll(allPatientList);
    } else {
      var result = allPatientList
          .where((p) =>
              p.nama.toLowerCase().contains(query.toLowerCase()) ||
              p.idPasienRs.toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredPatientList.assignAll(result);
    }
    patientCurrentPage.value = 1;
  }

  void clearProfileForm() {
    oldPasswordC.clear();
    newPasswordC.clear();
    isObscureOld.value = true;
    isObscureNew.value = true;
    myFullNameC.text = displayName.value;
    myUsernameC.text = box.read('username') ?? "";
  }

  // NAVIGASI
  void toggleSidebar() => isSidebarExpanded.toggle();

  String get currentHeaderTitle {
    if (activeIndex.value == 0) {
      return "Dashboard Overview";
    } else if (activeIndex.value == 1) {
      // Step disesuaikan karena tidak ada form upload
      switch (patientViewStep.value) {
        case 0:
          return "Data Pasien";
        case 1:
          return "Detail Pasien";
        case 2:
          return "Hasil Analisis AI";
        default:
          return "Data Pasien";
      }
    } else if (activeIndex.value == 2) {
      return "Pengaturan Profil";
    }
    return "Axon Vision";
  }

  void changeMenu(int index) {
    activeIndex.value = index;
    patientViewStep.value = 0;
    selectedPatient.value = null;
    if (index == 2) clearProfileForm();
  }

  void navigateToProfile() => changeMenu(2);

  void openPatientDetail(PatientModel patient) {
    selectedPatient.value = patient;
    patientViewStep.value = 1;
  }

  void openAnalysisResult(String analysisId) {
    selectedAnalysisId.value = analysisId;
    detailAnalysisData.value = {};
    isLoadingDetail.value = true;
    patientViewStep.value = 2; // Ubah jadi 2 karena form upload hilang
    fetchAnalysisDetail(analysisId);
  }

  void backToPreviousStep() {
    if (patientViewStep.value == 2) {
      // Dari Analisis kembali ke Detail / Dashboard
      if (selectedPatient.value == null) {
        activeIndex.value = 0;
        patientViewStep.value = 0;
      } else {
        patientViewStep.value = 1;
      }
      selectedAnalysisId.value = "";
    } else if (patientViewStep.value == 1) {
      // Dari Detail kembali ke List Pasien
      patientViewStep.value = 0;
      selectedPatient.value = null;
    }
  }

  void sortHistory(String order) {
    isSortNewest.value = order == 'Terbaru';
  }

  List<dynamic> get sortedPatientHistory {
    var tempList = List<dynamic>.from(selectedPatientHistory);

    DateTime parseDate(String dateStr) {
      try {
        var parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (e) {
        return DateTime(1970);
      }
      return DateTime(1970);
    }

    tempList.sort((a, b) {
      DateTime dateA = parseDate(a['tanggal_periksa'].toString());
      DateTime dateB = parseDate(b['tanggal_periksa'].toString());

      if (isSortNewest.value) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });
    return tempList;
  }

  // API ACTIONS
  Future<void> fetchMyProfile() async {
    try {
      String? token = getToken();
      if (token == null) return;
      var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/users/me/'),
          headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        currentUserId.value = data['id'];
        displayName.value = data['full_name'] ?? 'Dokter';
        displayRole.value = data['role'] ?? 'Doctor';
        myUsernameC.text = data['username'];
        myFullNameC.text = data['full_name'];
        if (data['avatar'] != null) profileImageUrl.value = data['avatar'];
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> saveProfile() async {
    if (currentUserId.value == 0) return;

    if (newPasswordC.text.isNotEmpty || oldPasswordC.text.isNotEmpty) {
      if (newPasswordC.text.isEmpty || oldPasswordC.text.isEmpty) {
        Get.snackbar(
          "Gagal",
          "Untuk ganti password, Wajib isi Password Lama dan Baru.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      String? token = getToken();
      Map<String, dynamic> bodyData = {
        "username": myUsernameC.text,
        "full_name": myFullNameC.text,
        "role": displayRole.value,
        "avatar": profileImageUrl.value,
      };

      if (newPasswordC.text.isNotEmpty) {
        bodyData["password"] = newPasswordC.text;
      }

      var response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/users/${currentUserId.value}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: json.encode(bodyData));

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Profil berhasil diperbarui",
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchMyProfile();
        clearProfileForm();
      } else {
        Get.snackbar("Gagal", "Gagal update profil: ${response.body}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        String? token = getToken();
        var request = http.MultipartRequest(
            'POST', Uri.parse('${ApiConfig.baseUrl}/users/upload-avatar/'));
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(http.MultipartFile.fromBytes(
            'file', await image.readAsBytes(),
            filename: image.name));

        Get.dialog(const Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
        var response = await http.Response.fromStream(await request.send());
        Get.back();

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['url'] != null) profileImageUrl.value = data['url'];
          Get.snackbar("Sukses", "Foto profil diperbarui",
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      } catch (e) {
        Get.back();
        debugPrint("Error: $e");
        Get.snackbar("Gagal", "Gagal upload avatar");
      }
    }
  }

  Future<void> fetchDashboardSummary() async {
    try {
      String? token = getToken();
      if (token == null) return;
      var response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/dashboard-summary/'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        dashboardSummary.value = {
          "total_pasien": data['total_pasien'],
          "total_menunggu": data['total_menunggu'],
          "total_selesai": data['total_selesai'],
        };
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> fetchPatients() async {
    try {
      isLoading.value = true;
      String? token = getToken();
      var response = await http.get(Uri.parse('${ApiConfig.baseUrl}/patients/'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        var data = jsonResponse.map((e) => PatientModel.fromJson(e)).toList();

        allPatientList.assignAll(data);
        filteredPatientList.assignAll(data);
        patientCurrentPage.value = 1;
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRiwayat() async {
    try {
      String? token = getToken();
      var response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/riwayat-semua/'),
          headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        riwayatScanList.value = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> fetchAnalysisDetail(String analysisId) async {
    isLoadingDetail.value = true;
    detailAnalysisData.value = {};

    final String url = "${ApiConfig.baseUrl}/analisis/$analysisId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['notes_dokter'] == null) {
          data['notes_dokter'] = "-";
        }
        if (data['notes_radiolog'] == null) {
          data['notes_radiolog'] = "Belum ada catatan radiolog";
        }

        detailAnalysisData.value = data;
      } else {
        Get.snackbar("Gagal", "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      Get.snackbar("Error", "Gagal koneksi ke server");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> saveDoctorNotes(String analysisId, String notes) async {
    try {
      isLoading.value = true;
      String? token = getToken();

      var response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/analisis/$analysisId/update-notes/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "notes_dokter": notes,
        }),
      );

      if (response.statusCode == 200) {
        detailAnalysisData['notes_dokter'] = notes;
        detailAnalysisData.refresh();

        Get.snackbar("Sukses", "Catatan dokter berhasil disimpan ke server",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("Gagal", "Gagal menyimpan: ${response.body}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan koneksi");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      String? token = getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout/'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      debugPrint("Gagal lapor ke server saat logout: $e");
    } finally {
      box.remove('token');
      box.remove('role');
      box.remove('username');
      Get.offAll(() => const LoginPage());
    }
  }
}
