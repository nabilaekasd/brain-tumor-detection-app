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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER ---
        PoppinsTextView(
          value: "Manajemen Pengguna",
          size: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        const PoppinsTextView(
          value:
              "Kelola akun Dokter, Radiolog, dan Admin (Edit, Hapus, Tambah).",
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),

        // --- SEARCH BAR ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: controller.searchC,
                    onChanged: controller.onSearchChanged,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 18,
                      ),
                      hintText: "Cari user...",
                      filled: true,
                      fillColor: const Color(0xffF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showUserDialog(context, isEdit: false),
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const PoppinsTextView(
                  value: "Tambah User",
                  size: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- TABEL DATA ---
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER TABEL
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xffF9FAFB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xffEEEEEE)),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: PoppinsTextView(
                          value: "ID",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: PoppinsTextView(
                          value: "NAMA LENGKAP",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "USERNAME",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "ROLE",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "STATUS",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: PoppinsTextView(
                          value: "AKSI",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // ISI TABEL
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.filteredList.isEmpty) {
                      return const Center(
                        child: PoppinsTextView(
                          value: "Data tidak ditemukan",
                          size: 13,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.currentUsers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final user = controller.currentUsers[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: PoppinsTextView(
                                  value: "#${user.id}",
                                  size: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.blueDark
                                          .withValues(alpha: 0.1),
                                      backgroundImage: (user.avatar != null &&
                                              user.avatar!.isNotEmpty)
                                          ? NetworkImage(
                                              "${ApiConfig.baseUrl}/${user.avatar}")
                                          : null,
                                      child: (user.avatar != null &&
                                              user.avatar!.isNotEmpty)
                                          ? null
                                          : PoppinsTextView(
                                              value: user.fullName.isNotEmpty
                                                  ? user.fullName[0]
                                                      .toUpperCase()
                                                  : "?",
                                              size: 11,
                                              color: AppColors.blueDark,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    PoppinsTextView(
                                      value: user.fullName,
                                      size: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: PoppinsTextView(
                                  value: user.username,
                                  size: 13,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildRoleBadge(user.role),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildStatusBadge(user.isActive),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        controller.fillFormForEdit(user);
                                        _showUserDialog(
                                          context,
                                          isEdit: true,
                                          user: user,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () =>
                                          _showDeleteConfirmDialog(user),
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

                // PAGINATION FOOTER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF9FAFB),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => PoppinsTextView(
                          value:
                              "Halaman ${controller.currentPage} dari ${controller.totalPages} (Total ${controller.filteredList.length})",
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => controller.prevPage(),
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.blueDark,
                              shape: BoxShape.circle,
                            ),
                            child: Obx(
                              () => PoppinsTextView(
                                value: "${controller.currentPage}",
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.nextPage(),
                            icon: const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  // --- DIALOG FORM (DENGAN MATA PASSWORD) ---
  void _showUserDialog(
    BuildContext context, {
    required bool isEdit,
    UserModel? user,
  }) {
    if (!isEdit) {
      controller.usernameC.clear();
      controller.newPasswordC.clear();
      // Reset mata
      controller.isObscureNew.value = true;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PoppinsTextView(
                    value: isEdit ? "Edit Pengguna" : "Tambah User",
                    size: 16,
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

                // FIELD PASSWORD LAMA (Pakai obscureState: controller.isObscureOld)
                _inputField(
                  "Password Lama",
                  controller.oldPasswordC,
                  hint: "Wajib jika ganti password",
                  obscureState: controller.isObscureOld,
                ),
                const SizedBox(height: 8),

                // FIELD PASSWORD BARU (Pakai obscureState: controller.isObscureNew)
                _inputField(
                  "Password Baru",
                  controller.newPasswordC,
                  hint: "Password baru",
                  obscureState: controller.isObscureNew,
                ),
              ] else ...[
                _inputField(
                  "Password",
                  controller.newPasswordC,
                  obscureState: controller.isObscureNew,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PoppinsTextView(
                          value: "Role",
                          size: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueDark,
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedRole.value,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "dokter",
                                    child: Text(
                                      "Dokter",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "radiolog",
                                    child: Text(
                                      "Radiolog",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "admin",
                                    child: Text(
                                      "Admin",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    controller.selectedRole.value = v!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEdit) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PoppinsTextView(
                            value: "Status",
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
                                  style: const TextStyle(fontSize: 12),
                                ),
                                value: controller.selectedStatus.value,
                                onChanged: (val) =>
                                    controller.selectedStatus.value = val,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => isEdit
                      ? controller.updateUser(user!.id)
                      : controller.addUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: PoppinsTextView(
                    value: isEdit ? "Simpan Perubahan" : "Simpan Data",
                    size: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(UserModel user) {
    Get.defaultDialog(
      title: "Hapus User",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      middleText: "Yakin ingin menghapus ${user.fullName}?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => controller.deleteUser(user.id),
    );
  }

  // --- WIDGET INPUT FIELD YANG SUDAH DI-UPDATE (TERIMA obscureState) ---
  Widget _inputField(
    String label,
    TextEditingController c, {
    bool readOnly = false,
    String? hint,
    RxBool? obscureState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: obscureState != null
              // Jika ada obscureState, pakai OBX agar ikon mata berfungsi
              ? Obx(
                  () => TextField(
                    controller: c,
                    obscureText: obscureState.value, // Bind ke variable
                    readOnly: readOnly,
                    style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      filled: readOnly,
                      fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      // IKON MATA
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
                  ),
                )
              // Jika tidak ada obscureState (Text biasa), render normal
              : TextField(
                  controller: c,
                  readOnly: readOnly,
                  style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    filled: readOnly,
                    fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
                    border: OutlineInputBorder(
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
