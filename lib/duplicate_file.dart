import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DuplicateFile extends StatefulWidget {
  final File file;

  final ValueChanged<bool> isSelected;

  final bool selected;

  DuplicateFile(this.file, this.isSelected, this.selected, {Key? key})
      : super(key: key);

  @override
  _DuplicateFileState createState() => _DuplicateFileState();
}

class _DuplicateFileState extends State<DuplicateFile> {
  bool? isSelected = false;
  String date = '';

  String size = '';

  @override
  void initState() {
    getDate().then((value) {
      if (mounted) {
        setState(() {
          date = value;
        });
      }
    });
    getSize().then((value) {
      if (mounted) {
        setState(() {
          size = value + ' Mb';
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isSelected = widget.selected;
    return CheckboxListTile(
      value: isSelected,
      onChanged: (b) {
        setState(() {
          isSelected = b;
          widget.isSelected(isSelected ?? false);
        });
      },
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(
            widget.file,
            height: 100,
            width: 100,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.file.path.split('/').last,
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget.file.path,
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  size,
                  style: Theme.of(context).textTheme.subtitle2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ) /*InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: ),
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
    )*/
        ;
  }

  Future<String> getDate() async {
    DateTime dateTime = await widget.file.lastModified();
    return dateTime.toString().split('.').first;
  }

  Future<String> getSize() async {
    int sizeInBytes = await widget.file.length();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb.toStringAsPrecision(2);
  }
}
