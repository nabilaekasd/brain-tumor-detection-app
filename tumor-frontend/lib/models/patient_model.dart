class PatientModel {
  final int id;
  final String nama;
  final String idPasienRs;
  final String tanggalLahir;
  final String statusPasien;
  final String jenisKelamin;

  PatientModel({
    required this.id,
    required this.nama,
    required this.idPasienRs,
    required this.tanggalLahir,
    required this.statusPasien,
    required this.jenisKelamin,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      nama: json['nama'],
      idPasienRs: json['id_pasien_rs'],
      tanggalLahir: json['tanggal_lahir'],
      statusPasien: json['status_pasien'] ?? "Aktif",
      jenisKelamin: json['jenis_kelamin'] ?? "Laki-laki",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nama": nama,
      "id_pasien_rs": idPasienRs,
      "tanggal_lahir": tanggalLahir,
      "status_pasien": statusPasien,
    };
  }
}
