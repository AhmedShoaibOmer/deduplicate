import 'package:deduplicate/scan_button.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'result.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('إلغاء التكرار'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.info),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationIcon: const FlutterLogo(),
                applicationName: 'De-Duplicate App',
                applicationVersion: '0.0.1',
                applicationLegalese: '©2022 De-Duplicate',
                children: <Widget>[
                  const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                          'برنامج لإيجاد الصور المكررة باستخدام خوارزمية MD5 or Message Digest 5'))
                ],
              );
            },
          ),
        ],
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
            child: Container(),
          ),
          Positioned(
            top: 100,
            width: 150,
            height: 150,
            child: Image.asset('assets/icon/icon.png'),
          ),
          Positioned(
            bottom: 150,
            child: InkWell(
              onTap: () async {
                if (await _permissionRequest(context)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Result(
                        key: GlobalKey(),
                      ),
                    ),
                  );
                }
              },
              child: ScanButton(),
            ),
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
