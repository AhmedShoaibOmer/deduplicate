
import 'package:flutter/material.dart';

class Scanning extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(
          ),
          SizedBox(height: 64,),
          Text('جاري البحث عن صور مكررة'),
          SizedBox(height: 16,),
          TextButton.icon(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.cancel), label: Text('Cancel'),),
        ]),
      ),
    );}

}
