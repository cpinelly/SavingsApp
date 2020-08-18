import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:savings_app/models/fund.dart';

class FundsRepository {
  String authToken;
  List<Fund> _funds = [];

  FundsRepository({this.authToken});

  // TODO: Remove, should not accesed directly.
  get funds => _funds;

  Future<List<Fund>> fetchUserFunds() async {
    print("Bearer $authToken");

    final response = await http.get(
        "https://flask-mymoney.herokuapp.com/api/funds",
        headers: {"Authorization": "Bearer $authToken"});

    List<dynamic> objects = json.decode(response.body);

    _funds.clear();
    _funds.addAll(objects.map((map) => Fund.fromMap(map)));

    print("from /api/funds/ : " + response.body);

    return _funds;
  }

  Future<Fund> updateBalance(String fundId, double change) async {
    var fund = _funds.firstWhere((element) => element.id == fundId);

    // TODO: Update database.

    fund.balance += change;
    return fund;
  }

  Fund fundForCategory(String categoryId) {

    if (_funds.length == 0) {
      throw Exception("No cached funds");
    }

    try{
      return _funds.firstWhere((element) => element.categories.map((e) => e.id).contains(categoryId));
    }catch (e, trace) {
      log("FundsRepository", error: e, stackTrace: trace);
      log("categoryId is " + categoryId);
    }

  }

  List<Fund> recoverUserFunds() {
    return _funds;
  }
}
