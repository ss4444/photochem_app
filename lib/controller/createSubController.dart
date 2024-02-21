import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photochem/config.dart';
import 'package:photochem/models/sub.dart';


class CreateSubController extends GetxController{
  TextEditingController mol_formula = TextEditingController();
  TextEditingController smiles = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController location = TextEditingController();

  Future<bool> submit() async{
    Substance substance = Substance(
      mol_formula: mol_formula.text.trim(),
      smiles: smiles.text.trim(),
      name: name.text.trim(),
      quantity: quantity.text.trim(),
      location: location.text.trim(),
    );
    Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 5), validateStatus: (status) => (status ?? 0) < 600), );
    String _apiUrl = ConfigUrl().apiURL + "/admin/add_substance";
    Map<String, dynamic> requestData = {
      'mol_formula': substance.mol_formula,
      'smiles': substance.smiles,
      'name': substance.name,
      'quantity': substance.quantity,
      'location': substance.location
    };
    final response = await dio.post(_apiUrl, data: requestData);
    if (response.statusCode == 201) {
      mol_formula.text = '';
      smiles.text = '';
      name.text = '';
      quantity.text = '';
      location.text = '';
      return true;
    } else{
      return false;
    }
  }
}