import 'package:deduplicator/deduplicator.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'result.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('إلغاء التكرار'),
      ),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 200,
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Positioned(top: 100, width: 150, height: 150, child: FlutterLogo()),
          Positioned(
            height: 150,
            width: 200,
            bottom: 150,
            child: ElevatedButton(
                onPressed: () async {
                  if (await _permissionRequest(context)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Result(key: GlobalKey(),),
                      ),
                    );
                  }
                },
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        CupertinoIcons.search,
                        size: 48,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text('ابحث عن الصور المكررة')
                    ])),
          )
        ],
      ),
    );
  }

  Future<bool> _permissionRequest(BuildContext context) async {
    final permissionValidator = EasyPermissionValidator(
      context: context,
      appName: 'De-Duplicate',
      appNameColor: Colors.red,
      cancelText: 'Cancel',
      //enableLocationMessage:
      //'Debe habilitar los permisos necesarios para utilizar la acción.',
      //goToSettingsText: 'Ir a Configuraciones',
      //permissionSettingsMessage:
      //'Necesita habilitar los permisos necesarios para que la aplicación funcione correctamente',
    );
    var result = await permissionValidator.storage();
    return result;
  }
}
