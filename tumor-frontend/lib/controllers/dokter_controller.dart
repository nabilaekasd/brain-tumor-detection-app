import 'dart:convert';
import 'dart:math';
import 'package:axon_vision/models/patient_model.dart';
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/helpers/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  var selectedDateFilter = Rxn<DateTime>();

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

  // FORM VARIABLES
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

  void filterHistoryByDate(DateTime date) {
    selectedDateFilter.value = date;
  }

  void clearDateFilter() {
    selectedDateFilter.value = null;
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
    patientViewStep.value = 2;
    fetchAnalysisDetail(analysisId);
  }

  void backToPreviousStep() {
    if (patientViewStep.value == 2) {
      if (selectedPatient.value == null) {
        activeIndex.value = 0;
        patientViewStep.value = 0;
      } else {
        patientViewStep.value = 1;
      }
      selectedAnalysisId.value = "";
    } else if (patientViewStep.value == 1) {
      patientViewStep.value = 0;
      selectedPatient.value = null;
    }
  }

  void sortHistory(String order) {
    isSortNewest.value = order == 'Terbaru';
  }

  List<dynamic> get sortedPatientHistory {
    var tempList = List<dynamic>.from(selectedPatientHistory);

    if (selectedDateFilter.value != null) {
      String filterDateStr =
          DateFormat('dd/MM/yyyy').format(selectedDateFilter.value!);
      tempList = tempList.where((scan) {
        return scan['tanggal_periksa'].toString() == filterDateStr;
      }).toList();
    }

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
    if (currentUserId.value == 0) {
      SnackbarHelper.showError(
          title: "Sistem Belum Siap",
          message:
              "Data Anda belum termuat sempurna. Silakan muat ulang halaman.");
      fetchMyProfile();
      return;
    }

    if (newPasswordC.text.isNotEmpty || oldPasswordC.text.isNotEmpty) {
      if (newPasswordC.text.isEmpty || oldPasswordC.text.isEmpty) {
        SnackbarHelper.showError(
          title: "Validasi Gagal",
          message:
              "Untuk mengganti kata sandi, WAJIB mengisi Password Lama dan Password Baru.",
        );
        return;
      }
      if (oldPasswordC.text == newPasswordC.text) {
        SnackbarHelper.showError(
          title: "Password Sama",
          message: "password baru tidak boleh sama dengan password lama Anda!",
        );
        return;
      }

      String pattern =
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$';
      RegExp regex = RegExp(pattern);

      if (!regex.hasMatch(newPasswordC.text)) {
        SnackbarHelper.showError(
          title: "Password Terlalu Lemah",
          message:
              "Password minimal 8 karakter, wajib mengandung huruf, angka, dan simbol.",
        );
        return;
      }
    }

    try {
      isLoading.value = true;
      String? token = getToken();
      if (token == null) return;

      Map<String, dynamic> bodyData = {
        "username": myUsernameC.text,
        "full_name": myFullNameC.text,
        "role": displayRole.value,
      };

      if (profileImageUrl.value.isNotEmpty) {
        bodyData["avatar"] = profileImageUrl.value;
      }

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Pop-up Sukses Besar!
        SnackbarHelper.showSuccessDialog(
            title: "Profil Tersimpan",
            description:
                "Data profil atau kata sandi Anda berhasil diperbarui.",
            onConfirm: () {} // Biarkan kosong agar hanya menutup pop-up
            );
        fetchMyProfile();
        clearProfileForm();
      } else if (response.statusCode == 422) {
        debugPrint("Alasan Error 422 dari Backend: ${response.body}");
        SnackbarHelper.showError(
          title: "Gagal Disimpan",
          message: "Data ditolak oleh server. Pastikan isian Anda sudah benar.",
        );
      } else {
        SnackbarHelper.showError(
          title: "Gagal Terhubung",
          message:
              "Terjadi kesalahan server dengan status: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Error saat saveProfile: $e");
      SnackbarHelper.showError(
          title: "Koneksi Terputus",
          message:
              "Gagal terhubung ke server. Periksa jaringan internet Anda.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final currentContext = Get.overlayContext;

      try {
        String? token = getToken();
        var request = http.MultipartRequest(
            'POST', Uri.parse('${ApiConfig.baseUrl}/users/upload-avatar/'));
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(http.MultipartFile.fromBytes(
            'file', await image.readAsBytes(),
            filename: image.name));

        if (currentContext != null) {
          showDialog(
            context: currentContext,
            barrierDismissible: false,
            builder: (context) => const Center(
                child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        var response = await http.Response.fromStream(await request.send());

        if (currentContext != null) {
          Navigator.of(currentContext, rootNavigator: true).pop();
        }

        await Future.delayed(const Duration(milliseconds: 300));

        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(response.body);
          if (data['url'] != null) profileImageUrl.value = data['url'];

          // Toast sukses sekilas (tidak mengganggu)
          SnackbarHelper.showSuccess(
            title: "Foto Berhasil Diunggah",
            message: "Foto profil Anda telah diperbarui secara otomatis.",
          );
        } else {
          SnackbarHelper.showError(
            title: "Gagal Mengunggah",
            message:
                "Server menolak file gambar Anda. Status: ${response.statusCode}",
          );
        }
      } catch (e) {
        if (currentContext != null) {
          Navigator.of(currentContext, rootNavigator: true).pop();
        }
        debugPrint("Error: $e");
        await Future.delayed(const Duration(milliseconds: 300));
        SnackbarHelper.showError(
            title: "Koneksi Terputus",
            message:
                "Gagal mengunggah foto. Pastikan koneksi stabil dan ukuran file tidak terlalu besar.");
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
        SnackbarHelper.showError(
            title: "Gagal Memuat Analisis",
            message: "Server mengembalikan status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
      SnackbarHelper.showError(
          title: "Koneksi Terputus",
          message: "Gagal menarik data analisis dari server.");
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        detailAnalysisData['notes_dokter'] = notes;
        detailAnalysisData.refresh();

        // Pakai Toast biar Dokter merasa prosesnya cepat dan ringan
        SnackbarHelper.showSuccess(
            title: "Catatan Disimpan",
            message: "Catatan medis berhasil ditambahkan ke dalam sistem.");
      } else {
        SnackbarHelper.showError(
            title: "Gagal Menyimpan",
            message: "Gagal menyimpan catatan: ${response.body}");
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: "Koneksi Terputus",
          message: "Terjadi kesalahan koneksi saat mencoba menyimpan catatan.");
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
