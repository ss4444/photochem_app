import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:photochem/admin_home.dart';
import 'package:photochem/camera.dart';
import 'package:photochem/auth.dart';
import 'package:camera/camera.dart';
import 'package:photochem/login.dart';
import 'package:photochem/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({required this.camera, super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SplashScreen(),
        '/home_admin': (context) => HomeAdmin(),
        '/login': (context) => Scaffold(body: Login()),
        '/camera': (context) => TakePictureScreen(camera: camera,),
        '/auth': (context) => Scaffold(body: SignIn()),
      },
      // home: Scaffold(
      //   body: Login(),
      // ),
    );
  }
}

