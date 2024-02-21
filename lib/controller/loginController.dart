import 'package:flutter/cupertino.dart';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:photochem/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photochem/config.dart';

class LoginController extends GetxController{
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  String _message = "";
  final storage = new FlutterSecureStorage();

  Future<bool> submit() async{
    User user = User(username: username.text.trim(), password: password.text.trim());

      bool validateResult = ValidateUser(user);
      if(validateResult) {
        bool serverResponse = await authenticateUser(user);
        if(serverResponse){
          return true;
        }else{
          await showMessage(
            context: Get.context!, title: 'Error', message: 'Error'
          );
          return false;
        }
      }else{
        await showMessage(context: Get.context!, title: "Error", message: _message);
        return false;
      }
  }

  bool ValidateUser(User user){
    if(user.username == null || user.password == null){
      _message = "Username or password cannot be empty";
      return false;
    }
    if(user.username.toString().isEmpty){
      _message = "Username cannot be empty";
      return false;
    }
    if(user.password.toString().isEmpty){
      _message = "Password cannot by empty";
      return false;
    }
    return true;
  }

  Future<bool> authenticateUser(User user) async{
    // Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 5), validateStatus: (status) => (status ?? 0) < 600), );
    Dio dio = Dio();
    String _apiUrl = ConfigUrl().apiURL + "/";

    try {
      Map<String, dynamic> requestData = {
        'username' : user.username,
        'password' : user.password,

      };
      final response = await dio.post(_apiUrl, data: requestData);
      // final response = await dio.get("https://catfact.ninja/fact");


      if(response.statusCode == 200){
        await storage.write(key: 'jwt', value: response.data['access_token']);
        // await storage.write(key: 'jwt', value: "111");
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