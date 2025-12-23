import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PasienDataSource extends DataGridSource {
  late List<DataGridRow> dataGridRows;
  final List<DataPasienModel> dataPasien;

  final String userRole;
  final Function(DataPasienModel)? onUploadTap;
  final Function(DataPasienModel)? onDetailTap;

  PasienDataSource({
    required this.dataPasien,
    required this.userRole,
    this.onUploadTap,
    this.onDetailTap,
  }) {
    dataGridRows = dataPasien
        .map<DataGridRow>(
          (pasien) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'id_patient', value: pasien.idPatient),
              DataGridCell(columnName: 'nama', value: pasien.namePatient),
              DataGridCell(
                columnName: 'tanggal_lahir',
                value: pasien.tanggalLahir,
              ),
              DataGridCell(columnName: 'status', value: pasien.status),
              DataGridCell(columnName: 'action', value: pasien),
            ],
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    int index = effectiveRows.indexOf(row);
    Color rowColor = index % 2 == 0 ? Colors.white : const Color(0xFFF9FAFB);

    return DataGridRowAdapter(
      color: rowColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'action') {
          return Container(
            alignment: Alignment.center,
            child: CustomRippleButton(
              onTap: () {
                final data = dataGridCell.value as DataPasienModel;

                if (userRole == 'radiolog' && onUploadTap != null) {
                  onUploadTap!(data);
                } else if (userRole == 'dokter' && onDetailTap != null) {
                  onDetailTap!(data);
                }
              },
              child: Tooltip(
                message: 'Lihat Detail Pasien',
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.horizontal(0.5)),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.grey,
                    size: SizeConfig.safeBlockHorizontal * 1.2,
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.only(left: SizeConfig.horizontal(1)),
          alignment: Alignment.centerLeft,
          child: PoppinsTextView(
            value: dataGridCell.value.toString(),
            size: SizeConfig.safeBlockHorizontal * 0.8,
            color: AppColors.black,
          ),
        );
      }).toList(),
    );
  }
}
