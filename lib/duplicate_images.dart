import 'dart:io';

import 'package:deduplicator/deduplicator.dart';
import 'package:flutter/material.dart';

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
    widget.duplicates.forEach((element) {
      duplicateFiles.addAll(element.duplicateFiles);
    });
  }

  void _delete(BuildContext context) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('هل انت متأكد؟'),
            content: Text(' سيتم حذف' '${selectedFiles.length}' ' عنصر'),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 56.0),
            child: GridView.count(
              //key: GlobalKey(),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: duplicateFiles
                  .map((e) => InkWell(
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
                        onTap: () => {
                          setState(() {
                            if (!selectedFiles.contains(e)) {
                              selectedFiles.add(e);
                            } else {
                              selectedFiles.remove(e);
                            }
                          })
                        },
                      ))
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
/*
PhotoViewGallery.builder(
scrollPhysics: const BouncingScrollPhysics(),
builder: (BuildContext context, int index) {
return PhotoViewGalleryPageOptions(
imageProvider: FileImage(duplicateFiles[index]),
initialScale: PhotoViewComputedScale.contained * 0.8,
heroAttributes: PhotoViewHeroAttributes(
tag: duplicateFiles[index].absolute),
);
},
itemCount: duplicateFiles.length,
loadingBuilder: (context, event) => Center(
child: Container(
width: 20.0,
height: 20.0,
child: CircularProgressIndicator(),
),
),
backgroundDecoration: BoxDecoration(
borderRadius: BorderRadius.circular(10),
),
//pageController: widget.pageController,
//onPageChanged: onPageChanged,
)*/
