import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:photochem/config.dart';
import 'package:photochem/models/reg.dart';
import 'package:dio/dio.dart';

class AuthController extends GetxController{
  TextEditingController last_name = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool is_admin = false;


  Future<void> submit() async{
  RegUser user = RegUser(
    last_name: last_name.text.trim(),
    name: name.text.trim(),
    username: username.text.trim(),
    password: password.text.trim(),
    is_admin: is_admin,
  );
  
        bool serverResponse = await regUser(user);
        if(serverResponse){
        }else{
          await showMessage(
            context: Get.context!, title: 'Error', message: 'Error'
          );
        }
  }

  Future<bool> regUser(RegUser user) async{
    Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 5), validateStatus: (status) => (status ?? 0) < 600), );
    String _apiUrl = ConfigUrl().apiURL + "/reg";

    try {
      Map<String, dynamic> requestData = {
        'last_name' : user.last_name,
        'name' : user.name,
        'username' : user.username,
        'password' : user.password,
        'is_admin' : user.is_admin,

      };
      final response = await dio.post(_apiUrl, data: requestData);

      if(response.statusCode == 200){
        return true;
      }else{
        return false;
      }
    } catch(e) {
      print(e);
      return false;
    }
  }
  showMessage({required BuildContext context, required String title, required String message}){
    showCupertinoDialog(context: context, builder: (context){
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(child: Text('Ok'), onPressed: (){
            Get.back();
          },)
        ],
      );
    });
  }
}