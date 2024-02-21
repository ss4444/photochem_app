import 'dart:async';
// import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/form_data.dart';
import 'package:get/route_manager.dart';
import 'package:photochem/config.dart';



class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storage = new FlutterSecureStorage();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Сделайте фото"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async{
              await storage.deleteAll();
              Navigator.of(context).pushReplacementNamed("/login");
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async{
              Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 90), validateStatus: (status) => (status ?? 0) < 600), );
              String _apiUrl = ConfigUrl().apiURL + "/user/get_history";
              final token = await storage.read(key: "jwt");
              final response = await dio.get(_apiUrl, options: Options(headers: {"Authorization": "Bearer ${token}"}));
              await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HistoryDisplay(
                  requests: response.data["history"],
                ),
              ),
            );
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
            _controller.pausePreview();
            String _apiUrl = ConfigUrl().apiURL + "/user/get_pred";
            Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 90), validateStatus: (status) => (status ?? 0) < 600), );
            String fileName = image.path.split('/').last;
            FormData formData = FormData.fromMap({
              "file": await MultipartFile.fromFile(image.path, filename: fileName),
            });
            var token = await storage.read(key: "jwt");
            final response = await dio.post(_apiUrl, data: formData, options: Options(headers: {"Authorization": "Bearer ${token}"}));
            if (response.statusCode == 400){
              Navigator.of(context).pop();
              await showMessage(context: context);
              _controller.resumePreview();
            }
            if (response.statusCode == 200){
             await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  mol_formula: response.data["mol_formula"],
                  smiles: response.data["smiles"],
                  name: response.data["name"],
                  location: response.data["location"],
                  quantity: response.data["quantity"],
                  mol_weight: response.data["mol_weight"],
                ),
              ),
            );
            Navigator.of(context).pop();
            _controller.resumePreview();
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  // final String imagePath;
  final String mol_formula;
  final String smiles;
  final String mol_weight;
  final String name;
  final String quantity;
  final String location;

  const DisplayPictureScreen({
    super.key,
    // required this.imagePath,
    required this.mol_formula,
    required this.smiles,
    required this.mol_weight,
    required this.name,
    required this.quantity,
    required this.location
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: SafeArea(
        // child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                // mainAxisAlignment: MainAxisSize.min,
                children: [
                  Center(child: Text(
                    mol_formula,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'name: ${name}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'smiles: ${smiles}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'wheight: ${mol_weight}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'quantity: ${quantity}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'location: ${location}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: Get.width / 2,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Загрузить еще раз"),
                    ),
                  )
                ],
              ),
            ),
          ),
        // )
      ),
    );
  }
}

class HistoryDisplay extends StatelessWidget {
  // final String imagePath;
  final List requests;

  const HistoryDisplay({
    super.key,
    required this.requests
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      body: SafeArea(
        child: ListView.separated(
          padding:  const EdgeInsets.symmetric(horizontal: 20),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.black,),
          itemBuilder: (context, i) => ListTile(
            title: Text("${requests[i]["mol_formula"]}"),
            subtitle: Text("${requests[i]["name"]}"),
            onTap: () async{
              await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HistoryItemDisplay(
                  mol_formula: requests[i]["mol_formula"],
                  smiles: requests[i]["smiles"],
                  name: requests[i]["name"],
                  mol_weight: requests[i]["mol_weight"].toString(),
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}


class HistoryItemDisplay extends StatelessWidget {
  // final String imagePath;
  final String mol_formula;
  final String smiles;
  final String mol_weight;
  final String name;


  const HistoryItemDisplay({
    super.key,
    required this.mol_formula,
    required this.smiles,
    required this.mol_weight,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: SafeArea(
        // child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                // mainAxisAlignment: MainAxisSize.min,
                children: [
                  Center(child: Text(
                    mol_formula,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'name: ${name}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'smiles: ${smiles}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'wheight: ${mol_weight}',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal)
                  ),
              
                ],
              ),
            ),
          ),
        // )
      ),
    );
  }
}

showMessage({required BuildContext context}){
    showCupertinoDialog(context: context, builder: (context){
      return CupertinoAlertDialog(
        title: const Text("Ошибка"),
        content: const Text("Попробуйте еще раз"),
        actions: [
          CupertinoDialogAction(child: const Text('Ok'), onPressed: (){
            Get.back();
          },)
        ],
      );
    });
  }

