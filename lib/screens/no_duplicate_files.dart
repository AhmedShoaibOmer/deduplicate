
import 'package:flutter/material.dart';

class NoDuplicateFiles extends StatelessWidget {
  const NoDuplicateFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 56,
              ),
              const SizedBox(height: 56,),
              const Text('لم يتم العثور على صور مكررة'),
              const SizedBox(height: 16,),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const BackButtonIcon(),
                label: const Text('رجوع'),
              ),
            ]),
      ),
    );
  }
}
