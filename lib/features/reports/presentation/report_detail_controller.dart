import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../data/report_model.dart';
import '../data/report_repository.dart';
import 'dashboard_controller.dart';

class ReportDetailController extends GetxController {
  ReportDetailController(this._repository);

  final ReportRepository _repository;
  final report = Rxn<ReportModel>();
  final isLoading = true.obs;
  final isDeleting = false.obs;
  final errorMessage = RxnString();
  int? _imageReportId;
  int? _imageVersion;
  Future<ReportImageRequest>? _imageFuture;

  @override
  void onInit() {
    super.onInit();
    load(Get.arguments);
  }

  Future<void> load(Object? id) async {
    final reportId = id is int ? id : int.tryParse(id?.toString() ?? '');
    if (reportId == null) {
      errorMessage.value = 'ID laporan tidak valid.';
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      report.value = await _repository.detail(reportId);
      _imageReportId = null;
      _imageVersion = null;
      _imageFuture = null;
      errorMessage.value = null;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ReportImageRequest> loadImage(ReportModel report) {
    final version = report.updatedAt?.microsecondsSinceEpoch ?? 0;
    if (_imageReportId != report.id ||
        _imageVersion != version ||
        _imageFuture == null) {
      _imageReportId = report.id;
      _imageVersion = version;
      _imageFuture = _repository.imageRequest(report.id, version: version);
    }
    return _imageFuture!;
  }

  void updateReport(ReportModel updated) {
    report.value = updated;
    _imageReportId = null;
    _imageVersion = null;
    _imageFuture = null;
  }

  Future<void> delete() async {
    final current = report.value;
    if (current == null || isDeleting.value) return;
    isDeleting.value = true;
    errorMessage.value = null;
    try {
      await _repository.delete(current.id);
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
      }
      Get.back();
      Get.snackbar('Laporan dihapus', 'Laporan berhasil dihapus.');
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isDeleting.value = false;
    }
  }
}
