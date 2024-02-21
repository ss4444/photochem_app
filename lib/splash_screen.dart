import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:photochem/config.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loginControl();

  }


  Future<void> loginControl() async {
    Dio dio = Dio();
    final storage = new FlutterSecureStorage();
    bool status = await AuthController.isLoginUser();
    if (status) {
      String _apiUrl = ConfigUrl().apiURL + "/is_admin";
      String? token = await storage.read(key: "jwt");
      final response = await dio.get(_apiUrl, options: Options(headers: {"Authorization": "Bearer ${token}"}));
      if (response.data["answer"]){
        Navigator.of(context).pushReplacementNamed("/home_admin");
        await Future.delayed(const Duration(milliseconds: 1500));
        FlutterNativeSplash.remove();
      }else{
        Navigator.of(context).pushReplacementNamed("/camera");
        await Future.delayed(const Duration(milliseconds: 1000));
        FlutterNativeSplash.remove();
      }
    } else {
      Navigator.of(context).pushReplacementNamed("/login");
      await Future.delayed(const Duration(milliseconds: 1000));
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(''),
      ),
    );
  }
}

class AuthController {
  static Future<bool> isLoginUser() async {
    final storage = new FlutterSecureStorage();
    String? token = await storage.read(key: "jwt");
    if (token == null) {
      return false;
    } else {
      return true;
    }
  }

}