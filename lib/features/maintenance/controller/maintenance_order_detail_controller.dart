import 'package:get/get.dart';
import 'package:salhly/features/maintenance/model/maintenance_order_model.dart';
import 'package:salhly/features/maintenance/service/maintenance_order_service.dart';

class MaintenanceOrderDetailController extends GetxController {
  final MaintenanceOrderService _service = MaintenanceOrderService();
  
  bool isLoading = false;
  MaintenanceOrderModel? order;

  Future<void> fetchMaintenanceOrder(int orderId) async {
    isLoading = true;
    update();

    try {
      final result = await _service.getMaintenanceOrder(orderId);
      if (result != null) {
        order = result;
      }
    } catch (e) {
      print('Error: $e');
    }

    isLoading = false;
    update();
  }
}
