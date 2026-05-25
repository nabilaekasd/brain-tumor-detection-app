import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/models/user_model.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManajemenUserMenu extends GetView<AdminController> {
  const ManajemenUserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan data di-fetch saat widget pertama kali di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUsers();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PoppinsTextView(
          value:
              "Kelola akun Dokter, Radiolog, dan Admin (Edit, Hapus, Tambah).",
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),

        // --- SEARCH BAR & ACTION BUTTONS ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 700;

              Widget searchBar = SizedBox(
                height: 38,
                child: TextField(
                  controller: controller.searchC,
                  onChanged: (val) => controller
                      .onSearchChanged(val), // Panggil method yang benar
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.grey, size: 18),
                    hintText: "Cari username atau nama...",
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xffF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );

              Widget refreshButton = SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => controller.fetchUsers(),
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 16),
                  label: const PoppinsTextView(
                    value: "Refresh",
                    size: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey.shade500, // Warna netral untuk refresh
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              );

              Widget addButton = SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => _showUserDialog(context, isEdit: false),
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 18),
                  label: const PoppinsTextView(
                    value: "Tambah User",
                    size: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchBar,
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: refreshButton),
                        const SizedBox(width: 8),
                        Expanded(child: addButton),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: searchBar),
                    const SizedBox(width: 12),
                    refreshButton,
                    const SizedBox(width: 8),
                    addButton,
                  ],
                );
              }
            },
          ),
        ),
        const SizedBox(height: 20),

        // --- TABEL DATA (RESPONSIVE) ---
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              // Minimum lebar tabel agar kolom tidak berdempetan
              double minTableWidth = 900;
              double tableWidth = constraints.maxWidth > minTableWidth
                  ? constraints.maxWidth
                  : minTableWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // HEADER TABEL
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: const BoxDecoration(
                                color: Color(0xffF9FAFB),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                border: Border(
                                    bottom:
                                        BorderSide(color: Color(0xffEEEEEE))),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: PoppinsTextView(
                                          value: "ID",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 3,
                                      child: PoppinsTextView(
                                          value: "NAMA LENGKAP",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "USERNAME",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "ROLE",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "STATUS",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 1,
                                      child: PoppinsTextView(
                                          value: "AKSI",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          textAlign: TextAlign.center)),
                                ],
                              ),
                            ),

                            // ISI TABEL
                            Expanded(
                              child: Obx(() {
                                if (controller.isLoading.value) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (controller.filteredList.isEmpty) {
                                  return const Center(
                                    child: PoppinsTextView(
                                        value: "Data tidak ditemukan",
                                        size: 12,
                                        color: Colors.grey),
                                  );
                                }
                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: controller.currentUsers.length,
                                  separatorBuilder: (c, i) => const Divider(
                                      height: 1, color: Color(0xffEEEEEE)),
                                  itemBuilder: (context, index) {
                                    final user = controller.currentUsers[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      color: Colors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: PoppinsTextView(
                                                  value: "#${user.id}",
                                                  size: 12,
                                                  color: Colors.grey)),
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors
                                                      .blueDark
                                                      .withValues(alpha: 0.1),
                                                  backgroundImage: (user
                                                                  .avatar !=
                                                              null &&
                                                          user.avatar!
                                                              .isNotEmpty)
                                                      ? NetworkImage(
                                                          "${ApiConfig.baseUrl}/${user.avatar}")
                                                      : null,
                                                  child: (user.avatar != null &&
                                                          user.avatar!
                                                              .isNotEmpty)
                                                      ? null
                                                      : PoppinsTextView(
                                                          value: user.fullName
                                                                  .isNotEmpty
                                                              ? user.fullName[0]
                                                                  .toUpperCase()
                                                              : "?",
                                                          size: 11,
                                                          color: AppColors
                                                              .blueDark,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                ),
                                                const SizedBox(width: 10),
                                                PoppinsTextView(
                                                    value: user.fullName,
                                                    size: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: PoppinsTextView(
                                                  value: user.username,
                                                  size: 12)),
                                          Expanded(
                                              flex: 2,
                                              child:
                                                  _buildRoleBadge(user.role)),
                                          Expanded(
                                              flex: 2,
                                              child: _buildStatusBadge(
                                                  user.isActive)),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  constraints:
                                                      const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.blue,
                                                      size: 18),
                                                  onPressed: () {
                                                    controller
                                                        .fillFormForEdit(user);
                                                    _showUserDialog(context,
                                                        isEdit: true,
                                                        user: user);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // PAGINATION FOOTER
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF9FAFB),
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.1))),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => PoppinsTextView(
                              value:
                                  "Halaman ${controller.currentPage} dari ${controller.totalPages} (Total ${controller.filteredList.length})",
                              size: 12,
                              color: Colors.grey,
                            )),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => controller.prevPage(),
                              icon: const Icon(Icons.chevron_left,
                                  size: 20, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppColors.blueDark,
                                  shape: BoxShape.circle),
                              child: Obx(() => PoppinsTextView(
                                    value: "${controller.currentPage}",
                                    color: Colors.white,
                                    size: 12,
                                  )),
                            ),
                            IconButton(
                              onPressed: () => controller.nextPage(),
                              icon: const Icon(Icons.chevron_right,
                                  size: 20, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- HELPERS TABEL ---
  Widget _buildRoleBadge(String role) {
    Color color;
    if (role == 'dokter') {
      color = Colors.blue;
    } else if (role == 'radiolog') {
      color = Colors.orange;
    } else {
      color = Colors.purple;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: PoppinsTextView(
          value: role.toUpperCase(),
          color: color,
          fontWeight: FontWeight.bold,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: PoppinsTextView(
          value: isActive ? "AKTIF" : "NONAKTIF",
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          size: 10,
        ),
      ),
    );
  }

  Widget _buildPasswordHint() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: PoppinsTextView(
              value:
                  "Password wajib minimal 8 karakter, terdiri dari kombinasi huruf, angka, dan simbol (contoh: @, \$, !, %, *, #, ?, &).",
              size: 12,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG FORM USER (RESPONSIF) ---
  void _showUserDialog(BuildContext context,
      {required bool isEdit, UserModel? user}) {
    // Reset form jika tambah user baru
    if (!isEdit) {
      controller.usernameC.clear();
      controller.fullNameC.clear();
      controller.newPasswordC.clear();
      controller.oldPasswordC.clear();
      controller.selectedRole.value = 'dokter';
      controller.selectedStatus.value = true;
      controller.isObscureNew.value = true;
      controller.isObscureOld.value = true;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding:
            const EdgeInsets.all(16), // Memberi margin pada layar kecil
        child: Container(
          width: 480, // Maksimal lebar dialog
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            // Agar form tidak overflow saat keyboard muncul
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PoppinsTextView(
                      value: isEdit ? "Edit Pengguna" : "Tambah User",
                      size: 14, // Sesuai permintaan (Judul = 14)
                      fontWeight: FontWeight.bold,
                      color: AppColors.blueDark,
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Form Inputs
                _inputField("Nama Lengkap", controller.fullNameC),
                const SizedBox(height: 16),
                _inputField("Username", controller.usernameC, readOnly: isEdit),
                const SizedBox(height: 16),

                if (isEdit) ...[
                  const PoppinsTextView(
                    value: "Ganti Password (Opsional)",
                    size: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _inputField("Password Lama", controller.oldPasswordC,
                      hint: "Wajib jika ganti password",
                      obscureState: controller.isObscureOld),
                  const SizedBox(height: 12),
                  _inputField("Password Baru", controller.newPasswordC,
                      hint: "Password baru",
                      obscureState: controller.isObscureNew),
                  _buildPasswordHint(),
                ] else ...[
                  _inputField("Password", controller.newPasswordC,
                      hint: "Buat kata sandi baru",
                      obscureState: controller.isObscureNew),
                  _buildPasswordHint(),
                ],

                const SizedBox(height: 16),

                // Role Dropdown (Full width untuk responsivitas)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsTextView(
                      value: "Role",
                      size: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueDark,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() => DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedRole.value,
                              isExpanded: true,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Colors.grey),
                              items: const [
                                DropdownMenuItem(
                                    value: "dokter",
                                    child: Text("Dokter",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins'))),
                                DropdownMenuItem(
                                    value: "radiolog",
                                    child: Text("Radiolog",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins'))),
                                DropdownMenuItem(
                                    value: "admin",
                                    child: Text("Admin",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins'))),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  controller.selectedRole.value = v;
                                }
                              },
                            ),
                          )),
                    ),
                  ],
                ),

                // Status Switch (Hanya saat edit)
                if (isEdit) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PoppinsTextView(
                        value: "Status Akun",
                        size: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueDark,
                      ),
                      SizedBox(
                        height: 40,
                        child: Obx(
                          () => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              controller.selectedStatus.value
                                  ? "Aktif"
                                  : "Nonaktif",
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'Poppins'),
                            ),
                            value: controller.selectedStatus.value,
                            onChanged: (val) =>
                                controller.selectedStatus.value = val,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEdit) {
                        controller.updateUser(user!.id);
                      } else {
                        controller.addUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: PoppinsTextView(
                      value: isEdit ? "Simpan Perubahan" : "Simpan Data",
                      size: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS INPUT FIELD ---
  Widget _inputField(String label, TextEditingController c,
      {bool readOnly = false, String? hint, RxBool? obscureState}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12, // Sesuai permintaan (Isi = 12)
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: obscureState != null
              ? Obx(() => TextField(
                    controller: c,
                    obscureText: obscureState.value,
                    readOnly: readOnly,
                    style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                      filled: readOnly,
                      fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureState.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => obscureState.toggle(),
                      ),
                    ),
                  ))
              : TextField(
                  controller: c,
                  readOnly: readOnly,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        const TextStyle(fontSize: 11, color: Colors.grey),
                    filled: readOnly,
                    fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
        ),
      ],
    );
  }
}
