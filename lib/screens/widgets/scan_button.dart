import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 1 / 10,
            width: MediaQuery.of(context).size.width * 3 / 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    const Color(0xFFffa40b),
                  ]),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                SizedBox(
                  width: 8,
                ),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Icon(
                      Icons.arrow_left_rounded,
                      size: 25.0,
                      color: Theme.of(context).colorScheme.secondary,
                    )),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: Text(
                  'ابحث عن الصور المكررة',
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                )),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
