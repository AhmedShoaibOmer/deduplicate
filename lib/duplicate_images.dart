import 'dart:io';

import 'package:flutter/material.dart';

import 'duplicate.dart';
import 'duplicate_file.dart';

class DuplicateImages extends StatefulWidget {
  final List<Duplicate> duplicates;
  const DuplicateImages(this.duplicates, {Key? key}) : super(key: key);

  @override
  State<DuplicateImages> createState() => _DuplicateImagesState();
}

class _DuplicateImagesState extends State<DuplicateImages> {
  List<File> selectedFiles = [];

  void _delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('الرجاء التأكيد'),
            content: Text(' عنصر' '${selectedFiles.length}' ' سيتم حذف'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () async {
                    // Remove the box
                    selectedFiles.forEach((e) async {
                      try {
                        await e.delete();
                        selectedFiles.remove(e);
                        widget.duplicates.removeWhere((d) {
                          return d.duplicateFiles.contains(e);
                        });
                        setState(() {});
                      } catch (e) {
                        print(e);
                      }
                    });

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('إستمرار')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('إلغاء'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الصور المكررة'),
        automaticallyImplyLeading: false,
        leading: selectedFiles.isEmpty
            ? const BackButton()
            : CloseButton(
                onPressed: () {
                  setState(() {
                    selectedFiles.clear();
                  });
                },
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                List<File> files = [];
                widget.duplicates.forEach((element) {
                  files.addAll(element.duplicateFiles);
                });
                if (selectedFiles.length == files.length) {
                  selectedFiles.clear();
                } else {
                  selectedFiles = files;
                }
              });
            },
            icon: Icon(Icons.check_box),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.separated(
            addAutomaticKeepAlives: false,
            padding: const EdgeInsets.all(8),
            itemCount: widget.duplicates.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildExpandableTile(
                  widget.duplicates[index].duplicateFiles);
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ElevatedButton.icon(
              onPressed: selectedFiles.isEmpty
                  ? null
                  : () async {
                      _delete(context);
                    },
              icon: const Icon(
                Icons.delete_forever,
              ),
              label: const Text('Delete Selected'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTile(List<File> files) {
    return ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          files.length == 2 ? 'نسختين' : '${files.length} نسخ',
        ),
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                return DuplicateFile(files[index], (bool value) {
                  setState(() {
                    if (value) {
                      selectedFiles.add(files[index]);
                    } else {
                      selectedFiles.remove(files[index]);
                    }
                  });
                  print("$index : $value");
                }, selectedFiles.contains(files[index]),
                    key: Key(files[index].path));
              }),
        ]);
  }
}
