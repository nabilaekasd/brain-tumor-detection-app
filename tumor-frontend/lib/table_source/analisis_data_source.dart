import 'package:axon_vision/models/data_analisis_model.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AnalisisDataSource extends DataGridSource {
  late List<DataGridRow> dataGridRows;
  final List<DataAnalisisModel> dataAnalisis;

  AnalisisDataSource(this.dataAnalisis) {
    dataGridRows = dataAnalisis
        .map<DataGridRow>(
          (data) => DataGridRow(
            cells: [
              DataGridCell(columnName: 'nama_patient', value: data.namePatient),
              DataGridCell(columnName: 'tanggal_scan', value: data.tanggalScan),
              DataGridCell(columnName: 'status', value: data.status),
              DataGridCell(columnName: 'estimasi', value: data.estimasi),
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
        if (dataGridCell.columnName == 'status') {
          String status = dataGridCell.value.toString();
          Color statusColor;
          Color statusBgColor;

          if (status.toLowerCase().contains('selesai')) {
            statusColor = Colors.green;
            statusBgColor = Colors.green.withValues(alpha: 0.1);
          } else if (status.toLowerCase().contains('analisis')) {
            statusColor = AppColors.blueDark;
            statusBgColor = AppColors.blueDark.withValues(alpha: 0.1);
          } else {
            statusColor = Colors.orange;
            statusBgColor = Colors.orange.withValues(alpha: 0.1);
          }

          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.horizontal(1)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: PoppinsTextView(
                value: status,
                size: SizeConfig.safeBlockHorizontal * 0.75,
                fontWeight: FontWeight.bold,
                color: statusColor,
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
