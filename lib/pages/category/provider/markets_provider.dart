import 'package:flutter/widgets.dart';
import 'package:ikinokat/models/province.dart';
import 'package:ikinokat/services/market_service.dart';

class MarketsProvider with ChangeNotifier {
  bool loading = true;
  // get markets by making api call
  List<ProvinceModel> provinces = [];
  MarketsProvider() {
    getData();
  }

  Future getData() async {
    ProvinceListModel res = await MarketAPI.getMarketData();
    provinces = res.list;
    loading = false;
    notifyListeners();
  }
}
