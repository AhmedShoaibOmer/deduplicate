import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Scanning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.twistingDots(
                leftDotColor: Theme.of(context).colorScheme.secondary,
                rightDotColor: const Color(0xFFffa40b),
                size: 100,
              ),
              SizedBox(
                height: 64,
              ),
              Text('جاري البحث عن صور مكررة'),
              SizedBox(
                height: 16,
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.cancel),
                label: Text('إلغاء'),
              ),
            ]),
      ),
    );
  }
}
