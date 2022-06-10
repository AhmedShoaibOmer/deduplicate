import 'dart:io';

import 'package:flutter/material.dart';

class DuplicateFile extends StatefulWidget {
  final File file;

  final ValueChanged<bool> isSelected;

  final bool selected;

  DuplicateFile(this.file, this.isSelected, this.selected, {Key? key}) : super(key: key);

  @override
  _DuplicateFileState createState() => _DuplicateFileState();
}

class _DuplicateFileState extends State<DuplicateFile> {
  bool isSelected = false;

  @override
  void initState() {
    isSelected = widget.selected;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: Image.file(
            widget.file,

          ),),
          isSelected
              ? const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
            ),
          )
              : Container()
        ],
      ),
    );
  }
}