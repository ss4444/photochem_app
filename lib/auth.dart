import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:photochem/controller/authController.dart';


class SignIn extends StatelessWidget{
  const SignIn({ super.key });

  @override
  Widget build(BuildContext context){
    AuthController controller = Get.put(AuthController());
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
                InputBox(hint: "Фамилия", txtController: controller.last_name, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "Имя", txtController: controller.name, isSecured: false),
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
                      await controller.submit();
                      Navigator.of(context).pushReplacementNamed("/login");
                    },
                    child: const Text('Зарегистрироваться'),
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
                      Navigator.pop(context, true);
                    },
                    child: const Text('Войти'),
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