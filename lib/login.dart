import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/route_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:photochem/config.dart';
import 'package:photochem/controller/loginController.dart';

class Login extends StatelessWidget{
  const Login({ super.key });

  @override
  Widget build(BuildContext context){
    LoginController controller = Get.put(LoginController());
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Вход',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "Username", txtController: controller.username, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "Password", txtController: controller.password, isSecured: true),
                const  SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: Get.width / 2,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
                      Dio dio = Dio();
                      final storage = new FlutterSecureStorage();
                      final gg = await controller.submit();
                      if(gg) {
                        String _apiUrl = ConfigUrl().apiURL + "/is_admin";
                        String? token = await storage.read(key: "jwt");
                        final response = await dio.get(_apiUrl, options: Options(headers: {"Authorization": "Bearer ${token}"}));
                        if (response.data["answer"]){
                          Navigator.of(context).pushReplacementNamed("/home_admin");
                        }else{
                          Navigator.of(context).pushReplacementNamed("/camera");
                        }
                      }
                    },
                    child: Text('Войти'),
                  ), 
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: Get.width / 2,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/auth');
                    },
                    child: Text('Регистрация'),
                  ), 
                ),
                ],),
          ),
        ),
      ),
    );
  }
}


Widget InputBox({required String hint, required TextEditingController txtController, required bool isSecured}){
  return Container(
    padding:const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey),
      ),
    child: TextField(
      obscureText: isSecured,
        controller: txtController,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
    ),
  );
}