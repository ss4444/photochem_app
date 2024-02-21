import "package:dio/dio.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:get/route_manager.dart';
import 'package:get/instance_manager.dart';
import "package:photochem/config.dart";
import "package:photochem/controller/createSubController.dart";


class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}
  final int gg = 1;



class _HomeAdminState extends State<HomeAdmin> {
  List substances = [];
  @override
  void initState() {
  super.initState();
  getSub();
}
Future<void> getSub() async{
  Dio dio = Dio();
  String _apiUrl = ConfigUrl().apiURL + "/admin/get_substances";
  final response = await dio.get(_apiUrl);
  setState(() {
    substances = response.data;
  });
}

  @override
  Widget build(BuildContext context) {
    final storage = new FlutterSecureStorage();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Вещества"),
        actions: [
          IconButton(
            onPressed: () async{
              Navigator.of(context).pushReplacementNamed("/login");
              await storage.deleteAll();
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: substances.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.black,),
          itemBuilder: (context, i) => ListTile(
            title: Text("${substances[i]["mol_formula"]}"),
            subtitle: Text("${substances[i]["name"]}"),
            onTap: () async{
              final bool? needUpdate = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubItem(
                    smiles: substances[i]["smiles"],
                    mol_formula: substances[i]["mol_formula"],
                    name: substances[i]["name"],
                    location: substances[i]["location"],
                    quantity: substances[i]["quantity"],
                  ),
                )
              );

              if (needUpdate != null && needUpdate) {
                setState(() {
                  substances = substances..removeAt(i);
                });
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final bool? needUpdate = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateSub(substances: substances),
            )
          );

          if (needUpdate != null && needUpdate) {
            getSub();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SubItem extends StatelessWidget {
  final String smiles;
  final String mol_formula;
  final String name;
  final String quantity;
  final String location;

  const SubItem({
    super.key,
    required this.mol_formula,
    required this.smiles,
    required this.name,
    required this.location,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Вещества"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Center(child: Text(
                  mol_formula,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'name: ${name}',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'smilse: ${smiles}',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'quantity: ${quantity}',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'location: ${location}',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: Get.width / 2,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
                      Dio dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 5), validateStatus: (status) => (status ?? 0) < 600), );
                      String _apiUrl = ConfigUrl().apiURL + "/admin/substance_delete";
                      await dio.delete(_apiUrl, data: {"smiles": smiles});
                      // Navigator.pushReplacement(
                      //     context,
                      //     PageRouteBuilder(
                      //       transitionDuration: Duration.zero,
                      //       pageBuilder: (_, __, ___) => HomeAdmin(),
                      //     )
                      //   );
                      Navigator.pop(context, true);
                    },
                    child: const Text("Удалить"),
                  ),
                )
              ],
            )
          )
        )
      ),
    );
  }
}


class CreateSub extends StatelessWidget {
  final List<dynamic> substances;
  const CreateSub({super.key, required this.substances});

  @override
  Widget build(BuildContext context) {
    CreateSubController controller = Get.put(CreateSubController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Добавить вещество"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: InputBox(hint: "formula", txtController: controller.mol_formula, isSecured: false),
                ),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "smiles", txtController: controller.smiles, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "name", txtController: controller.name, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "quantity", txtController: controller.quantity, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                InputBox(hint: "location", txtController: controller.location, isSecured: false),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: Get.width / 2,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async{
                      final bool response = await controller.submit();
                      if (response) {
                        Navigator.of(context).pop(true);
                      } else{
                        showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text("Ошибка"),
                              content: const Text("Проверьте данные"),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text("Ok"),
                                  onPressed: () {
                                    Get.back();
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text("Создать"),
                  ),
                )
              ],
            ),
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