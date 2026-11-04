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
  final errorMessage = RxnString();

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
      errorMessage.value = null;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete() async {
    final current = report.value;
    if (current == null) return;
    try {
      await _repository.delete(current.id);
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().refreshDashboard();
      }
      Get.back();
      Get.snackbar('Laporan dihapus', 'Laporan berhasil dihapus.');
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    }
  }
}
