import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/helpers/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/models/user_model.dart';
import 'package:axon_vision/models/patient_model.dart';
import 'package:axon_vision/models/log_model.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:image_picker/image_picker.dart';

class AdminController extends GetxController {
  // ========================================================================
  // 1. UI & DATA VARIABLES
  // ========================================================================
  var activeMenuIndex = 0.obs;
  var isSidebarExpanded = true.obs;
  var headerTitle = 'Dashboard Overview'.obs;
  var displayName = 'Administrator'.obs;
  var displayRole = 'Admin'.obs;

  var isLoading = false.obs;
  var userList = <UserModel>[].obs;
  var filteredList = <UserModel>[].obs;

  var patientList = <PatientModel>[].obs;
  var filteredPatientList = <PatientModel>[].obs;

  var logList = <LogModel>[].obs;
  var filteredLogList = <LogModel>[].obs;
  var selectedLogRole = "Semua".obs;

  var selectedDateRange = Rxn<DateTimeRange>();

  // Pagination
  var currentPage = 1.obs;
  var patientCurrentPage = 1.obs;
  var itemsPerPage = 9;

  var profileImageUrl = "".obs;
  var currentUserId = 0.obs;

  // ========================================================================
  // 2. FORM VARIABLES
  // ========================================================================
  final searchC = TextEditingController();
  final usernameC = TextEditingController();
  final fullNameC = TextEditingController();

  final namaPasienC = TextEditingController();
  final idRmC = TextEditingController();
  final tglLahirC = TextEditingController();
  var statusPasien = "Aktif".obs;
  var jenisKelaminPasien = "Laki-laki".obs;

  // Password Controllers
  final oldPasswordC = TextEditingController();
  final newPasswordC = TextEditingController();

  // Visibility Password
  var isObscureOld = true.obs;
  var isObscureNew = true.obs;

  var selectedRole = 'dokter'.obs;
  var selectedStatus = true.obs;

  // STORAGE (Untuk Token)
  final box = GetStorage();

  // ========================================================================
  // 3. LIFECYCLE
  // ========================================================================
  @override
  void onInit() {
    super.onInit();
    updateHeaderTitle(0);
    fetchUsers();
    fetchPatients();
    fetchLogs();
    fetchMyProfile();
  }

  @override
  void onClose() {
    searchC.dispose();
    usernameC.dispose();
    fullNameC.dispose();
    oldPasswordC.dispose();
    newPasswordC.dispose();
    super.onClose();
  }

  // ========================================================================
  // 4. HELPER: GET TOKEN
  // ========================================================================
  String? getToken() {
    // Ambil token dari penyimpanan lokal
    String? token = box.read('token');

    if (token == null || token.isEmpty) {
      Get.offAll(
        () => const LoginPage(),
      ); // Tendang ke Login jika tidak ada token
      return null;
    }
    return token;
  }

  // ========================================================================
  // 5. NAVIGATION & PAGINATION
  // ========================================================================
  void toggleSidebar() => isSidebarExpanded.toggle();

  void changeMenu(int index) {
    activeMenuIndex.value = index;
    updateHeaderTitle(index);
  }

  void navigateToProfile() => changeMenu(4);

  void updateHeaderTitle(int index) {
    switch (index) {
      case 0:
        headerTitle.value = 'Dashboard Overview';
        break;
      case 1:
        headerTitle.value = 'Kelola Akun Pengguna';
        break;
      case 2:
        headerTitle.value = 'Manajemen Data Pasien';
        break;
      case 3:
        headerTitle.value = 'Monitoring Log Sistem';
        break;
      case 4:
        headerTitle.value = 'Pengaturan Profil';
        break;
      default:
        headerTitle.value = 'Admin Panel';
    }
  }

  List<UserModel> get currentUsers {
    int start = (currentPage.value - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    return filteredList.sublist(start, min(end, filteredList.length));
  }

  int get totalPages => (filteredList.length / itemsPerPage).ceil();
  void nextPage() {
    if (currentPage.value < totalPages) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 1) currentPage.value--;
  }

  void onSearchChanged(String val) {
    if (val.isEmpty) {
      filteredList.value = userList;
    } else {
      filteredList.value = userList.where((u) {
        return u.fullName.toLowerCase().contains(val.toLowerCase()) ||
            u.username.toLowerCase().contains(val.toLowerCase());
      }).toList();
    }
    currentPage.value = 1;
  }

  List<PatientModel> get currentPatients {
    int start = (patientCurrentPage.value - 1) * itemsPerPage;
    int end = start + itemsPerPage;
    return filteredPatientList.sublist(start, min(end, filteredList.length));
  }

  int get totalPatientPages {
    if (filteredPatientList.isEmpty) return 1;
    return (filteredPatientList.length / itemsPerPage).ceil();
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
      filteredPatientList.value = patientList;
    } else {
      filteredPatientList.value = patientList
          .where(
            (p) =>
                p.nama.toLowerCase().contains(query.toLowerCase()) ||
                p.idPasienRs.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    patientCurrentPage.value = 1;
  }

  // ========================================================================
  // 6. API ACTIONS (CRUD)
  // ========================================================================

  /// [READ] FETCH USERS
  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      String? token = getToken(); // Gunakan Helper getToken
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        userList.value = data.map((e) => UserModel.fromJson(e)).toList();
        filteredList.value = userList;
        currentPage.value = 1;
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Error 401",
          "Token tidak valid. Silakan logout & login ulang.",
        );
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// [CREATE] ADD USER
  Future<void> addUser() async {
    if (usernameC.text.isEmpty ||
        newPasswordC.text.isEmpty ||
        fullNameC.text.isEmpty) {
      SnackbarHelper.showError(
        title: "Peringatan",
        message:
            "Semua isian (Username, Nama, dan Password) wajib diisi untuk membuat user baru.",
      );
      return;
    }

    // RegEx Level Dewa
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

    try {
      String? token = getToken();
      if (token == null) return;

      var body = json.encode({
        "username": usernameC.text,
        "password": newPasswordC.text,
        "full_name": fullNameC.text,
        "role": selectedRole.value,
      });

      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Tutup modal/dialog tambah user
        SnackbarHelper.showSuccess(
            title: "Sukses",
            message: "Akun ${fullNameC.text} berhasil dibuat.");
        _clearForm();
        fetchUsers();
      } else {
        var err = json.decode(response.body);
        SnackbarHelper.showError(
          title: "Gagal Menambahkan",
          message: err['detail'] ??
              "Gagal menyimpan ke server (Code ${response.statusCode})",
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: "Error Jaringan",
        message: "Gagal menyambung ke server: $e",
      );
    }
  }

  /// [UPDATE] UPDATE USER
  /// [UPDATE] UPDATE USER
  Future<void> updateUser(int userId,
      {bool isUpdatingOwnProfile = false}) async {
    // Validasi Password Keamanan Tinggi
    if (newPasswordC.text.isNotEmpty || oldPasswordC.text.isNotEmpty) {
      if (newPasswordC.text.isEmpty || oldPasswordC.text.isEmpty) {
        SnackbarHelper.showError(
          title: "Validasi Gagal",
          message:
              "Untuk mengganti kata sandi, Anda WAJIB mengisi Password Lama dan Baru.",
        );
        return;
      }

      if (oldPasswordC.text == newPasswordC.text) {
        SnackbarHelper.showError(
          title: "Password Sama",
          message: "Password baru tidak boleh sama dengan password yang lama.",
        );
        return;
      }

      // RegEx Level Dewa
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
      String? token = getToken();
      if (token == null) return;

      // 👇 PERBAIKAN BUG PAYLOAD DI SINI 👇
      Map<String, dynamic> data = {
        "username": usernameC.text,
        "full_name": fullNameC.text,
        "role": selectedRole.value,
        "is_active": selectedStatus
            .value, // Pastikan ini terkirim sebagai boolean (true/false)
      };

      // Jangan kirim password kalau kosong (biar backend tidak error)
      if (newPasswordC.text.isNotEmpty) {
        data["password"] = newPasswordC.text;
      }

      // INI OBAT ANTI-KLONING FOTO PROFIL:
      // Hanya kirim/timpa avatar JIKA admin sedang edit profilnya SENDIRI!
      if (isUpdatingOwnProfile && profileImageUrl.value.isNotEmpty) {
        data["avatar"] = profileImageUrl.value;
      }

      var response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika sedang edit user lain dari tabel, tutup dialog modalnya
        if (!isUpdatingOwnProfile) Get.back();

        SnackbarHelper.showSuccessDialog(
          title: "Sukses Tersimpan",
          description: "Data profil telah berhasil diperbarui di dalam sistem.",
          onConfirm: () {}, // Kosongkan
        );

        oldPasswordC.clear();
        newPasswordC.clear();
        fetchUsers();
        if (isUpdatingOwnProfile) fetchMyProfile();
      } else {
        SnackbarHelper.showError(
          title: "Gagal Menyimpan",
          message:
              "Update gagal ditolak oleh server (Code ${response.statusCode})",
        );
      }
    } catch (e) {
      SnackbarHelper.showError(
        title: "Koneksi Terputus",
        message: "Gagal terhubung dengan server.",
      );
    }
  }

  /// [DELETE] DELETE USER
  Future<void> deleteUser(int userId) async {
    try {
      String? token = getToken();
      if (token == null) return;

      var response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Get.back(); // Jika dia dalam dialog
        SnackbarHelper.showSuccess(
            title: "User Dihapus",
            message: "Data user berhasil dihapus dari sistem.");
        fetchUsers();
      } else {
        SnackbarHelper.showError(
            title: "Gagal Menghapus",
            message:
                "Tidak dapat menghapus data ini (Code ${response.statusCode})");
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: "Koneksi Gagal",
          message: "Terjadi masalah saat mencoba menghubungi server.");
    }
  }

  // AMBIL DATA PASIEN (READ)
  Future<void> fetchPatients() async {
    isLoading.value = true;
    try {
      String? token = getToken();
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/patients/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        patientList.value = data.map((e) => PatientModel.fromJson(e)).toList();
        filteredPatientList.value = patientList;
      }
    } catch (e) {
      debugPrint("Error Fetch Patients: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Tambah Pasien (CREATE)
  Future<void> addPatient() async {
    if (namaPasienC.text.isEmpty || idRmC.text.isEmpty) {
      SnackbarHelper.showError(
          title: "Data Belum Lengkap",
          message: "Nama Pasien dan ID Rekam Medis (RM) wajib diisi!");
      return;
    }

    try {
      String? token = getToken();
      var body = json.encode({
        "nama": namaPasienC.text,
        "id_pasien_rs": idRmC.text,
        "tanggal_lahir": tglLahirC.text,
        "status_pasien": statusPasien.value,
        "jenis_kelamin": jenisKelaminPasien.value,
      });

      var response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/patients/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Tutup form modal
        SnackbarHelper.showSuccess(
            title: "Sukses", message: "Data Pasien berhasil ditambahkan.");
        clearPatientForm();
        fetchPatients();
      } else {
        SnackbarHelper.showError(
            title: "Gagal Menyimpan",
            message:
                "Gagal mendaftarkan pasien (Code: ${response.statusCode})");
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: "Error Jaringan", message: "Koneksi ke server terputus.");
    }
  }

  // Edit/Soft Delete Pasien
  Future<void> updatePatient(int id) async {
    try {
      String? token = getToken();
      var body = json.encode({
        "nama": namaPasienC.text,
        "id_pasien_rs": idRmC.text,
        "tanggal_lahir": tglLahirC.text,
        "status_pasien": statusPasien.value,
        "jenis_kelamin": jenisKelaminPasien.value,
      });

      var response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/patients/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        SnackbarHelper.showSuccess(
            title: "Pasien Diperbarui",
            message: "Perubahan data pasien telah berhasil disimpan.");
        clearPatientForm();
        fetchPatients();
      } else {
        SnackbarHelper.showError(
            title: "Gagal Update",
            message: "Sistem menolak update data pasien ini.");
      }
    } catch (e) {
      SnackbarHelper.showError(
          title: "Error", message: "Jaringan sedang bermasalah.");
    }
  }

  // Monitoring Log
  Future<void> fetchLogs() async {
    isLoading.value = true;
    try {
      String? token = getToken();
      List<String> params = [];

      if (selectedLogRole.value != "Semua") {
        params.add("role=${selectedLogRole.value.toLowerCase()}");
      }

      if (selectedDateRange.value != null) {
        String start =
            selectedDateRange.value!.start.toIso8601String().split('T')[0];
        String end =
            selectedDateRange.value!.end.toIso8601String().split('T')[0];
        params.add("start_date=$start");
        params.add("end_date=$end");
      }

      String queryString = "";
      if (params.isNotEmpty) {
        queryString = "?${params.join("&")}";
      }

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/logs/$queryString'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        logList.value = data.map((e) => LogModel.fromJson(e)).toList();
        filteredLogList.value = logList;
      }
    } catch (e) {
      debugPrint("Error Logs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
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
      debugPrint("Gagal lapor server: $e");
    } finally {
      box.remove('token');
      box.remove('role');
      box.remove('username');

      Get.offAll(() => const LoginPage());
    }
  }

  // Ambil Data Profil
  Future<void> fetchMyProfile() async {
    try {
      String? token = getToken();
      if (token == null) return;

      var response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        currentUserId.value = data['id'];
        fullNameC.text = data['full_name'];
        usernameC.text = data['username'];

        displayName.value = data['full_name'];
        displayRole.value = data['role'];

        if (data['role'] != null) {
          selectedRole.value = data['role'];
        }

        if (data['avatar'] != null) {
          profileImageUrl.value = data['avatar'];
        }
      }
    } catch (e) {
      debugPrint("Gagal ambil profil: $e");
    }
  }

  // Simpan Perubahan
  Future<void> saveProfile() async {
    if (currentUserId.value == 0) {
      SnackbarHelper.showError(
        title: "Error",
        message: "Gagal memuat ID Admin. Silakan muat ulang halaman.",
      );
      return;
    }
    await updateUser(currentUserId.value);
    await fetchMyProfile();
  }

  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _uploadAvatar(image);
    }
  }

  Future<void> _uploadAvatar(XFile image) async {
    final currentContext = Get.overlayContext;
    try {
      String? token = getToken();
      if (token == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/users/upload-avatar/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await image.readAsBytes(),
          filename: image.name,
        ),
      );

      // Loading Indicator
      if (currentContext != null) {
        showDialog(
          context: currentContext,
          barrierDismissible: false,
          builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Tutup Loading Indicator
      if (currentContext != null) {
        Navigator.of(currentContext, rootNavigator: true).pop();
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);

        if (data['url'] != null) {
          profileImageUrl.value = data['url'];
        } else if (data['avatar_url'] != null) {
          profileImageUrl.value = data['avatar_url'];
        }

        SnackbarHelper.showSuccess(
            title: "Foto Berhasil Diunggah",
            message: "Foto profil admin berhasil diganti.");
      } else {
        SnackbarHelper.showError(
            title: "Upload Ditolak",
            message:
                "Server tidak bisa memproses gambar Anda (Code: ${response.statusCode})");
      }
    } catch (e) {
      if (currentContext != null) {
        Navigator.of(currentContext, rootNavigator: true).pop();
      }
      await Future.delayed(const Duration(milliseconds: 300));

      SnackbarHelper.showError(
          title: "Koneksi Terputus", message: "Gagal mengirimkan foto profil.");
    }
  }

  // --- Helpers ---
  void _clearForm() {
    usernameC.clear();
    fullNameC.clear();
    oldPasswordC.clear();
    newPasswordC.clear();
    selectedRole.value = 'dokter';
    selectedStatus.value = true;
    isObscureOld.value = true;
    isObscureNew.value = true;
  }

  void fillFormForEdit(UserModel user) {
    fullNameC.text = user.fullName;
    usernameC.text = user.username;
    selectedRole.value = user.role;
    selectedStatus.value = user.isActive;
    oldPasswordC.clear();
    newPasswordC.clear();
    isObscureOld.value = true;
    isObscureNew.value = true;
  }

  void fillPatientForm(PatientModel p) {
    namaPasienC.text = p.nama;
    idRmC.text = p.idPasienRs;
    tglLahirC.text = p.tanggalLahir;
    statusPasien.value = p.statusPasien;
    jenisKelaminPasien.value = p.jenisKelamin;
  }

  void clearPatientForm() {
    namaPasienC.clear();
    idRmC.clear();
    tglLahirC.clear();
    statusPasien.value = "Aktif";
    jenisKelaminPasien.value = "Laki-laki";
  }

  void filterLogByRole(String role) {
    selectedLogRole.value = role;
    fetchLogs();
  }

  void pickDateRange(BuildContext context) async {
    var config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: const Color(0xff2C3E50),
      yearTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      dayTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      weekdayLabelTextStyle:
          GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.grey),
      controlsTextStyle:
          GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
      okButton: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: PoppinsTextView(
              value: "APPLY",
              color: Color(0xff2C3E50),
              fontWeight: FontWeight.bold,
              fontSize: 14)),
      cancelButton: const PoppinsTextView(
          value: "CANCEL",
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
    );

    List<DateTime?> initialValue = [];
    if (selectedDateRange.value != null) {
      initialValue = [
        selectedDateRange.value!.start,
        selectedDateRange.value!.end
      ];
    }

    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(375, 480),
      value: initialValue,
      borderRadius: BorderRadius.circular(15),
    );
    if (results != null &&
        results.length == 2 &&
        results[0] != null &&
        results[1] != null) {
      selectedDateRange.value =
          DateTimeRange(start: results[0]!, end: results[1]!);
      fetchLogs();
    }
  }

  void clearDateFilter() {
    selectedDateRange.value = null;
    fetchLogs();
  }
}
