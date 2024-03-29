import 'package:flutter/widgets.dart';
import 'package:ikinokat/models/order.dart';
import 'package:ikinokat/services/order_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GetOrdersProvider with ChangeNotifier {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  List<OrderModel> userOrders = [];
  bool loading = true;
  int _page;

  GetOrdersProvider() {
    getUserOrders();
  }

  Future getUserOrders({bool refresh = false}) async {
    _page = 1;
    OrderListModel res = await OrderAPI.getOrdersData('my-orders?page=$_page');
    userOrders = res.list;
    loading = false;
    _page = 2;
    if (refresh) {
      OrderListModel res =
          await OrderAPI.getOrdersData('my-orders?page=$_page');
      userOrders = res.list;
      loading = false;
      refreshController.refreshCompleted();
    }
    notifyListeners();
  }

  Future loadMoreProducts({bool refresh = false}) async {
    OrderListModel res = await OrderAPI.getOrdersData('my-orders?page=$_page');
    userOrders = res.list;
    loading = false;
    if (userOrders.length < 100) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
    _page += 1;
    notifyListeners();
  }
}
