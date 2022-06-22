import 'dart:io';

import 'package:deduplicate/no_duplicate_files.dart';
import 'package:deduplicator/deduplicator.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'duplicate.dart';

class DuplicateImages extends StatefulWidget {
  final List<Duplicate> duplicates;
  const DuplicateImages(this.duplicates, {Key? key}) : super(key: key);

  @override
  State<DuplicateImages> createState() => _DuplicateImagesState();
}

class _DuplicateImagesState extends State<DuplicateImages> {
  List<File> selectedFiles = [];
  List<File> duplicateFiles = [];

  @override
  void initState() {
    super.initState();
    print(
        'Duplicates Images initState : duplicates data length : ${widget.duplicates.length}, duplicates data : ${widget.duplicates.toString()}');

    widget.duplicates.forEach((element) {
      duplicateFiles.addAll(element.duplicateFiles);
    });

    print(
        'Duplicates Images initState : duplicate Files length : ${duplicateFiles.length}, duplicate files data : ${widget.duplicates.toString()}');
  }

  void _delete(BuildContext context) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('هل انت متأكد؟'),
            content: Text('سيتم حذف' ' ${selectedFiles.length} ' 'عنصر'),
            actions: [
              // The "Yes" button
              ElevatedButton(
                  onPressed: () async {
                    // Close the dialog
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('حذف')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('إلغاء'))
            ],
          );
        }).then((value) {
      if (value ?? false) {
        List<String> paths = [];
        selectedFiles.forEach((element) {
          paths.add(element.path);
        });
        Deduplicator.deleteFiles(paths).then((value) {
          if (value as bool) {
            List<Duplicate> toRemove = [];
            selectedFiles.forEach((e) {
              widget.duplicates.forEach((d) {
                if (d.duplicateFiles.contains(e)) {
                  if (d.duplicateFiles.length > 2) {
                    duplicateFiles.remove(e);
                    d.duplicateFiles.remove(e);
                    print('did i called : $e');
                  } else {
                    print('why am i called : $e');
                    toRemove.add(d);
                  }
                }
              });
            });
            setState(() {
              if (toRemove.length > 0) {
                toRemove.forEach((e) {
                  e.duplicateFiles.forEach((element) {
                    duplicateFiles.remove(element);
                  });
                  widget.duplicates.remove(e);
                });
              }
              selectedFiles.clear();
            });
            setState(() {});
            String message = paths.length == 1
                ? 'تم حذف الصورة المحددة'
                : 'تم حذف الصور المحددة';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return duplicateFiles.length == 0
        ? const NoDuplicateFiles()
        : Scaffold(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 56.0),
                  child: GridView.count(
                    physics: ClampingScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16.0),
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    children: duplicateFiles
                        .map(
                          (e) => InkWell(
                            child: Hero(
                              tag: e.absolute,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                      e,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: Checkbox(
                                        value: selectedFiles.contains(e),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value!) {
                                              selectedFiles.add(e);
                                            } else {
                                              selectedFiles.remove(e);
                                            }
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onTap: () async {
                              await showDialog(
                                barrierColor: Colors.black54,
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Stack(
                                        children: [
                                          PhotoView(
                                            imageProvider: FileImage(e),
                                            initialScale: PhotoViewComputedScale
                                                    .contained *
                                                0.8,
                                            heroAttributes:
                                                PhotoViewHeroAttributes(
                                                    tag: e.absolute),
                                            loadingBuilder: (context, event) =>
                                                Center(
                                              child: Container(
                                                width: 20.0,
                                                height: 20.0,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            backgroundDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          Positioned(
                                            top: 16,
                                            left: 16,
                                            child: Material(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              elevation: 4.0,
                                              child: CloseButton(
                                                color: const Color(0xFFffa40b),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 72,
                                            left: 16,
                                            child: Material(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              elevation: 4.0,
                                              child: Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      const Color(0xFFffa40b),
                                                ),
                                                child: Checkbox(
                                                  value:
                                                      selectedFiles.contains(e),
                                                  activeColor:
                                                      const Color(0xFFffa40b),
                                                  onChanged: (bool? value) {
                                                    setState(
                                                      () {
                                                        if (value!) {
                                                          selectedFiles.add(e);
                                                        } else {
                                                          selectedFiles
                                                              .remove(e);
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
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
}
