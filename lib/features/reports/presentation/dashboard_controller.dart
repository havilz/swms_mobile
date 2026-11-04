import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../data/report_model.dart';
import '../data/report_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final ReportRepository _repository;
  final reports = <ReportModel>[].obs;
  final counts = <String, int?>{
    'all': null,
    'pending': null,
    'in_progress': null,
    'completed': null,
  }.obs;
  final selectedStatus = RxnString();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  var currentPage = 1;
  var lastPage = 1;

  Future<void> refreshDashboard() async {
    await Future.wait([loadCounts(), loadReports(reset: true)]);
  }

  Future<void> loadCounts() async {
    try {
      final results = await Future.wait([
        _repository.list(perPage: 1),
        _repository.list(status: 'pending', perPage: 1),
        _repository.list(status: 'in_progress', perPage: 1),
        _repository.list(status: 'completed', perPage: 1),
      ]);
      counts.assignAll({
        'all': results[0].total,
        'pending': results[1].total,
        'in_progress': results[2].total,
        'completed': results[3].total,
      });
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    }
  }

  Future<void> loadReports({bool reset = false}) async {
    if (isLoading.value) return;
    if (reset) {
      currentPage = 1;
      reports.clear();
    } else if (currentPage >= lastPage) {
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.list(
        status: selectedStatus.value,
        page: currentPage,
      );
      reports.addAll(result.items);
      currentPage = result.page + 1;
      lastPage = result.lastPage;
    } on ApiException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectStatus(String? status) async {
    selectedStatus.value = status;
    await loadReports(reset: true);
  }
}
