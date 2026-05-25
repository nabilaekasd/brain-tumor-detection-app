import 'dart:async';
import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/controllers/dokter_controller.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart'; // Wajib ada
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'; // Wajib ada
import 'package:flutter/foundation.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class DetailAnalisisPage extends StatefulWidget {
  final String analysisId;
  final String role;

  const DetailAnalisisPage({
    super.key,
    required this.analysisId,
    required this.role,
  });

  @override
  State<DetailAnalisisPage> createState() => _DetailAnalisisPageState();
}

class _DetailAnalisisPageState extends State<DetailAnalisisPage> {
  dynamic get activeController {
    if (widget.role.toUpperCase() == 'DOKTER') {
      return Get.find<DokterController>();
    } else {
      return Get.find<RadiologController>();
    }
  }

  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController doctorNotesController = TextEditingController();

  // --- STATE UNTUK 2D DYNAMIC SLICES ---
  int _axis2D = 2; // 0: Sagittal, 1: Coronal, 2: Axial
  String _label2D = "all"; // all, netc, snfh, et, rc

  double _sliceIdx = 75;
  double _fetchSliceIdx = 75;
  int _maxSlice = 155;
  Timer? _debounceTimer;

  // --- STATE UNTUK 3D ---
  String _label3D = "all";
  bool _showBrain3D = true;

  int _quarterTurns = 0;
  bool _isInverted = false;

  @override
  void initState() {
    super.initState();
    final currentCtrl = activeController;

    if (currentCtrl.detailAnalysisData.isEmpty ||
        currentCtrl.detailAnalysisData['id'].toString() != widget.analysisId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentCtrl.fetchAnalysisDetail(widget.analysisId).then((_) {
          _setupInitialSlices(currentCtrl.detailAnalysisData);
        });
      });
    } else {
      _setupInitialSlices(currentCtrl.detailAnalysisData);
    }
  }

  void _setupInitialSlices(Map data) {
    if (data.containsKey('shape')) {
      List shape = data['shape'];
      setState(() {
        _maxSlice = shape[_axis2D] - 1;
        _sliceIdx = _maxSlice / 2;
        _fetchSliceIdx = _sliceIdx;
      });
    }
  }

  void _onAxisChanged(int? newAxis) {
    if (newAxis != null) {
      final data = activeController.detailAnalysisData;
      List shape = data['shape'] ?? [155, 240, 240];
      setState(() {
        _axis2D = newAxis;
        _maxSlice = shape[_axis2D] - 1;
        _sliceIdx = _maxSlice / 2;
        _fetchSliceIdx = _sliceIdx;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _transformationController.dispose();
    doctorNotesController.dispose();
    super.dispose();
  }

  void _zoomIn() =>
      _transformationController.value *= Matrix4.diagonal3Values(1.2, 1.2, 1.0);
  void _zoomOut() =>
      _transformationController.value *= Matrix4.diagonal3Values(0.8, 0.8, 1.0);
  void _rotateImage() =>
      setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
  void _toggleContrast() => setState(() => _isInverted = !_isInverted);
  void _resetView() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _quarterTurns = 0;
      _isInverted = false;
    });
  }

  // --- URL GENERATOR ---
  String _getDynamic2DUrl() {
    return "${ApiConfig.baseUrl}/analisis/${widget.analysisId}/slice?axis=$_axis2D&idx=${_fetchSliceIdx.toInt()}&label=$_label2D&t=${DateTime.now().millisecondsSinceEpoch}";
  }

  String _getDynamic3DUrl(Map data) {
    Map paths = data['paths_3d'] ?? {};
    String key = _showBrain3D ? _label3D : "${_label3D}_nobrain";
    String rawPath = paths[key] ?? "";
    if (rawPath.isEmpty) {
      rawPath = paths['all'] ?? "";
    }
    String filename = rawPath.split('/').last;
    return Uri.encodeFull(
        "${ApiConfig.baseUrl}/get-image/$filename?t=${DateTime.now().millisecondsSinceEpoch}");
  }

  void _openFullscreen(String imageUrl) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: InteractiveViewer(
            transformationController: TransformationController(),
            minScale: 0.1,
            maxScale: 5.0,
            child: _buildImageContent(imageUrl, BoxFit.contain),
          ),
        ),
      ),
      barrierColor: Colors.black,
    );
  }

  void _openFullscreen3D(String url) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: WebView3DWidget(url: url)),
      ),
      barrierColor: Colors.black,
    );
  }

  Widget _buildImageContent(String url, BoxFit fit) {
    return RotatedBox(
      quarterTurns: _quarterTurns,
      child: _isInverted
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1,
                0,
                0,
                0,
                255,
                0,
                -1,
                0,
                0,
                255,
                0,
                0,
                -1,
                0,
                255,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image.network(url, fit: fit, key: ValueKey(url)),
            )
          : Image.network(url, fit: fit, key: ValueKey(url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDokter = widget.role.toUpperCase() == 'DOKTER';
    final currentCtrl = activeController;

    return Material(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (context, constraints) {
          double availableHeight = constraints.maxHeight - 32;

          return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Obx(() {
                if (currentCtrl.isLoadingDetail.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = currentCtrl.detailAnalysisData;
                if (data.isEmpty) {
                  return const Center(
                      child: PoppinsTextView(
                          value: "Data tidak tersedia", color: Colors.grey));
                }

                if (data['notes_dokter'] != null &&
                    doctorNotesController.text.isEmpty &&
                    data['notes_dokter'] != "-") {
                  doctorNotesController.text = data['notes_dokter'];
                }

                Widget imageViewer = Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: TabBar(
                              indicatorColor: AppColors.blueDark,
                              indicatorWeight: 3,
                              labelColor: AppColors.blueDark,
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  fontSize: 12),
                              unselectedLabelColor: Colors.grey,
                              tabs: const [
                                Tab(
                                    icon: Icon(Icons.image_outlined, size: 18),
                                    text: 'Interactive 2D Slices'),
                                Tab(
                                    icon: Icon(Icons.view_in_ar_rounded,
                                        size: 18),
                                    text: '3D Volume Render'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // --- TAB 1: 2D SLICES ---
                                Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: InteractiveViewer(
                                                transformationController:
                                                    _transformationController,
                                                minScale: 0.1,
                                                maxScale: 5.0,
                                                child: _buildImageContent(
                                                    _getDynamic2DUrl(),
                                                    BoxFit.contain),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 16,
                                              right: 16,
                                              child: InkWell(
                                                onTap: () => _openFullscreen(
                                                    _getDynamic2DUrl()),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  child: const Icon(
                                                      Icons.fullscreen,
                                                      color: Colors.white,
                                                      size: 20),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 16,
                                              left: 0,
                                              right: 0,
                                              child: Center(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      _buildToolIcon(
                                                          Icons.zoom_in,
                                                          onTap: _zoomIn),
                                                      const SizedBox(width: 8),
                                                      _buildToolIcon(
                                                          Icons.zoom_out,
                                                          onTap: _zoomOut),
                                                      const SizedBox(width: 8),
                                                      _buildToolIcon(
                                                          Icons.rotate_right,
                                                          onTap: _rotateImage),
                                                      const SizedBox(width: 8),
                                                      _buildToolIcon(
                                                          Icons.contrast,
                                                          onTap:
                                                              _toggleContrast),
                                                      const SizedBox(width: 8),
                                                      _buildToolIcon(
                                                          Icons.refresh,
                                                          onTap: _resetView),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 16,
                                          bottom: 12,
                                          left: 16,
                                          right: 16),
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildDropdown(
                                                  label: "Sudut Pandang (Axis)",
                                                  value: _axis2D,
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: 0,
                                                        child: PoppinsTextView(
                                                            value: "Sagittal",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: 1,
                                                        child: PoppinsTextView(
                                                            value: "Coronal",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: 2,
                                                        child: PoppinsTextView(
                                                            value: "Axial",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                  onChanged: (val) =>
                                                      _onAxisChanged(
                                                          val as int?),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildDropdown(
                                                  label: "Tampilkan Mask",
                                                  value: _label2D,
                                                  items: const [
                                                    DropdownMenuItem(
                                                        value: "all",
                                                        child: PoppinsTextView(
                                                            value: "Semua",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: "netc",
                                                        child: PoppinsTextView(
                                                            value:
                                                                "NETC (Merah)",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: "snfh",
                                                        child: PoppinsTextView(
                                                            value:
                                                                "SNFH (Biru)",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: "et",
                                                        child: PoppinsTextView(
                                                            value: "ET (Hijau)",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                    DropdownMenuItem(
                                                        value: "rc",
                                                        child: PoppinsTextView(
                                                            value: "RC (Ungu)",
                                                            size: 11,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  ],
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _label2D = val.toString();
                                                      _fetchSliceIdx =
                                                          _sliceIdx;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const PoppinsTextView(
                                                  value: "Slice: ",
                                                  size: 12,
                                                  fontWeight: FontWeight.bold),
                                              Text("${_sliceIdx.toInt()}",
                                                  style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Colors.blue)),
                                              Expanded(
                                                child: Slider(
                                                  value: _sliceIdx,
                                                  min: 0,
                                                  max: _maxSlice.toDouble(),
                                                  divisions: _maxSlice > 0
                                                      ? _maxSlice
                                                      : 1,
                                                  activeColor:
                                                      AppColors.blueDark,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      _sliceIdx = val;
                                                    });
                                                    if (_debounceTimer
                                                            ?.isActive ??
                                                        false) {
                                                      _debounceTimer!.cancel();
                                                    }
                                                    _debounceTimer = Timer(
                                                        const Duration(
                                                            milliseconds: 150),
                                                        () {
                                                      setState(() {
                                                        _fetchSliceIdx = val;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                // --- TAB 2: 3D VOLUME ---
                                Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      bottom:
                                                          Radius.circular(11)),
                                              child: WebView3DWidget(
                                                  url: _getDynamic3DUrl(data),
                                                  key: ValueKey(
                                                      "${_label3D}_${_showBrain3D}_${data['id']}")),
                                            ),
                                            Positioned(
                                              bottom: 16,
                                              right: 16,
                                              child: PointerInterceptor(
                                                child: InkWell(
                                                  onTap: () =>
                                                      _openFullscreen3D(
                                                          _getDynamic3DUrl(
                                                              data)),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black54,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6)),
                                                    child: const Icon(
                                                        Icons.fullscreen,
                                                        color: Colors.white,
                                                        size: 20),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 14),
                                      color: Colors.white,
                                      width: double.infinity,
                                      child: Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 16,
                                        runSpacing: 12,
                                        children: [
                                          // --- KUBU KIRI: Toggle Brain ---
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                    Icons.psychology_outlined,
                                                    size: 18,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(width: 10),
                                              const PoppinsTextView(
                                                value: "Otak (Brain)",
                                                size: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(width: 8),
                                              Switch(
                                                value: _showBrain3D,
                                                activeColor: AppColors.blueDark,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _showBrain3D = val;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),

                                          // --- KUBU KANAN: Chips Kategori Tumor ---
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _build3DChip("Full", "all",
                                                  AppColors.blueDark),
                                              _build3DChip("NETC", "netc",
                                                  const Color(0xffe41a1c)),
                                              _build3DChip("SNFH", "snfh",
                                                  const Color(0xff377eb8)),
                                              _build3DChip("ET", "et",
                                                  const Color(0xff4daf4a)),
                                              _build3DChip("RC", "rc",
                                                  const Color(0xff984ea3)),
                                            ],
                                          ),
                                        ],
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
                );

                // ==========================================
                // WIDGET KANAN: PANEL INFO & METRIK
                // ==========================================
                Widget infoPanel = Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- INFO PASIEN ---
                              _buildSectionTitle('Informasi Pasien'),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                  'Nama Pasien', data['nama_pasien'] ?? "-",
                                  isBold: true),
                              _buildInfoRow('ID Medis', data['id_rm'] ?? "-"),
                              _buildInfoRow(
                                  'Waktu Scan', data['waktu_scan'] ?? "-"),

                              _buildDivider(),

                              // --- TABEL METRIK (DOSEN) ---
                              if (data['metrics'] != null) ...[
                                _buildSectionTitle('Evaluasi Metrik AI'),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Table(
                                    border: TableBorder.symmetric(
                                        inside: BorderSide(
                                            color: Colors.grey.shade200)),
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(2)
                                    },
                                    children: [
                                      TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey.shade100),
                                          children: [
                                            _tableCell("Kelas", isHeader: true),
                                            _tableCell("Recall",
                                                isHeader: true),
                                            _tableCell("Specificity",
                                                isHeader: true),
                                          ]),
                                      ..._buildMetricRows(data['metrics']),
                                    ],
                                  ),
                                ),
                                _buildDivider(),
                              ],

                              // --- KETERANGAN WARNA ---
                              _buildSectionTitle('Keterangan Segmentasi'),
                              const SizedBox(height: 10),
                              Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Builder(builder: (context) {
                                    List<dynamic> detectedRegions =
                                        data['detected_regions'] ??
                                            [1, 2, 3, 4];
                                    Map<int, Map<String, dynamic>> legendData =
                                        {
                                      1: {
                                        "label": "Necrotic Tumor Core (NETC)",
                                        "color": const Color(0xffe41a1c)
                                      },
                                      2: {
                                        "label": "Peritumoral Edema (SNFH)",
                                        "color": const Color(0xff377eb8)
                                      },
                                      3: {
                                        "label": "Enhancing Tumor (ET)",
                                        "color": const Color(0xff4daf4a)
                                      },
                                      4: {
                                        "label": "Resection Cavity (RC)",
                                        "color": const Color(0xff984ea3)
                                      },
                                    };
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          detectedRegions.map<Widget>((id) {
                                        if (legendData.containsKey(id)) {
                                          return _buildLegendItem(
                                              legendData[id]!["color"] as Color,
                                              legendData[id]!["label"]
                                                  as String);
                                        }
                                        return const SizedBox.shrink();
                                      }).toList(),
                                    );
                                  })),

                              _buildDivider(),

                              // --- CATATAN RADIOLOG ---
                              _buildSectionTitle('Catatan Teknis (Radiolog)'),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                child: PoppinsTextView(
                                    value: (data['notes_radiolog'] == null ||
                                            data['notes_radiolog'] == "" ||
                                            data['notes_radiolog'] == "-")
                                        ? "Radiolog tidak menambahkan catatan"
                                        : data['notes_radiolog'],
                                    size: 12,
                                    color: Colors.black54),
                              ),

                              _buildDivider(),

                              // --- CATATAN DOKTER ---
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionTitle('Catatan Dokter'),
                                  Icon(
                                      isDokter
                                          ? Icons.edit
                                          : Icons.lock_outline,
                                      size: 14,
                                      color: Colors.grey),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (isDokter)
                                TextField(
                                  controller: doctorNotesController,
                                  minLines: 3,
                                  maxLines: 4,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins', fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Tulis diagnosis atau tindakan...',
                                    hintStyle: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.grey,
                                        fontSize: 12),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200)),
                                  child: PoppinsTextView(
                                      value: (data['notes_dokter'] == null ||
                                              data['notes_dokter'] == "")
                                          ? 'Belum ada catatan dari dokter.'
                                          : data['notes_dokter'],
                                      color: Colors.black54,
                                      size: 12),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // --- TOMBOL AKSI ---
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => currentCtrl.backToPreviousStep(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const PoppinsTextView(
                                  value: 'Kembali',
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  size: 12),
                            ),
                          ),
                          if (isDokter) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  String isiCatatan =
                                      doctorNotesController.text;
                                  currentCtrl.saveDoctorNotes(
                                      widget.analysisId, isiCatatan);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: AppColors.blueDark,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const PoppinsTextView(
                                    value: 'Simpan',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    size: 12),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                );

                // Responsive Layout
                if (constraints.maxWidth < 1000) {
                  return Column(
                    children: [
                      SizedBox(height: 400, child: imageViewer),
                      const SizedBox(height: 16),
                      Expanded(child: infoPanel),
                    ],
                  );
                } else {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          flex: 6,
                          child: SizedBox(
                              height: availableHeight, child: imageViewer)),
                      const SizedBox(width: 20),
                      Expanded(
                          flex: 4,
                          child: SizedBox(
                              height: availableHeight, child: infoPanel)),
                    ],
                  );
                }
              }));
        }));
  }

  // --- WIDGET HELPER ---

  Widget _build3DChip(String label, String val, Color activeColor) {
    bool isSelected = _label3D == val;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (selected) {
        if (selected) setState(() => _label3D = val);
      },
    );
  }

  Widget _buildDropdown(
      {required String label,
      required dynamic value,
      required List<DropdownMenuItem> items,
      required Function(dynamic) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
            value: label,
            size: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xffF5F7FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isDense: true,
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: PoppinsTextView(
            value: text,
            size: 11,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
            color: isHeader ? Colors.black87 : Colors.black54),
      ),
    );
  }

  List<TableRow> _buildMetricRows(Map metrics) {
    List<TableRow> rows = [];
    metrics.forEach((className, data) {
      rows.add(TableRow(children: [
        _tableCell(className),
        _tableCell(data['recall'].toString()),
        _tableCell(data['specificity'].toString()),
      ]));
    });
    return rows;
  }

  Widget _buildSectionTitle(String title) {
    return PoppinsTextView(
        value: title,
        fontWeight: FontWeight.bold,
        size: 14,
        color: Colors.black87);
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoppinsTextView(value: label, color: Colors.grey.shade600, size: 12),
          const SizedBox(width: 16),
          Expanded(
              child: PoppinsTextView(
                  value: value,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  size: 12,
                  textAlign: TextAlign.right,
                  color: isBold ? Colors.black : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, color: Colors.white, size: 16)),
    );
  }

  Widget _buildDivider() {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(color: Color(0xFFEEEEEE), height: 1));
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(
              child: PoppinsTextView(
                  value: label, size: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class WebView3DWidget extends StatefulWidget {
  final String url;
  const WebView3DWidget({super.key, required this.url});

  @override
  State<WebView3DWidget> createState() => _WebView3DWidgetState();
}

class _WebView3DWidgetState extends State<WebView3DWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 1. Pendaftaran Platform Web
    if (kIsWeb) {
      WebViewPlatform.instance = WebWebViewPlatform();
    }

    // 2. Inisialisasi Controller
    _controller = WebViewController();

    // 3. Konfigurasi Spesifik Mobile (Android/iOS)
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        );
    } else {
      // Jika di Web, iframe otomatis mengeksekusi JS bawaan.
      // Kita langsung matikan loading karena fitur deteksi onPageFinished tidak didukung di Web.
      _isLoading = false;
    }

    // 4. Load URL (Berlaku untuk Web dan Mobile)
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }
}
