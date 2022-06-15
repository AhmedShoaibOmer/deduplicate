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
            selectedFiles.forEach((e) {
              List<Duplicate> toRemove = [];
              widget.duplicates.forEach((d) {
                if (d.duplicateFiles.contains(e)) {
                  if (d.duplicateFiles.length > 2) {
                    d.duplicateFiles.remove(e);
                    print('did i called : $e');
                  } else {
                    print('why am i called : $e');
                    toRemove.add(d);
                  }
                }
              });
              setState(() {
                if (toRemove.length > 0) {
                  toRemove.forEach((element) {
                    widget.duplicates.remove(element);
                  });
                }
                selectedFiles.clear();
              });
              String message = paths.length == 1
                  ? 'تم حذف الصورة المحددة'
                  : 'تم حذف الصور المحددة';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            });
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
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
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
        title: Text(
          files.length == 2 ? 'نسختين' : '${files.length} نسخ',
        ),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            crossAxisSpacing: 10.0,
            children: files
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
        ]);
  }
}

/*
class DuplicateImages extends StatefulWidget {
  final List<Duplicate> duplicates;
  const DuplicateImages(this.duplicates, {Key? key}) : super(key: key);

  @override
  State<DuplicateImages> createState() => _DuplicateImagesState();
}

class _DuplicateImagesState extends State<DuplicateImages> {
  List<File> selectedFiles = [];

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
            selectedFiles.forEach((e) {
              List<Duplicate> toRemove = [];
              widget.duplicates.forEach((d) {
                if (d.duplicateFiles.contains(e)) {
                  if (d.duplicateFiles.length > 2) {
                    d.duplicateFiles.remove(e);
                    print('did i called : $e');
                  } else {
                    print('why am i called : $e');
                    toRemove.add(d);
                  }
                }
              });
              setState(() {
                if (toRemove.length > 0) {
                  toRemove.forEach((element) {
                    widget.duplicates.remove(element);
                  });
                }
                selectedFiles.clear();
              });
              String message = paths.length == 1
                  ? 'تم حذف الصورة المحددة'
                  : 'تم حذف الصور المحددة';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            });
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
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
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
        title: Text(
          files.length == 2 ? 'نسختين' : '${files.length} نسخ',
        ),
        children: [
          ListView.builder(
              physics: const BouncingScrollPhysics(),
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
*/

/*
class DuplicateImages extends StatefulWidget {
  final List<Duplicate> duplicates;
  const DuplicateImages(this.duplicates, {Key? key}) : super(key: key);

  @override
  State<DuplicateImages> createState() => _DuplicateImagesState();
}

class _DuplicateImagesState extends State<DuplicateImages> {
  List<File> selectedFiles = [];
  List<File> duplicates = [];

  @override
  void initState() {
    widget.duplicates.forEach((element) {
      duplicates.addAll(element.duplicateFiles);
    });
    super.initState();
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
            selectedFiles.forEach((e) {
              List<Duplicate> toRemove = [];
              widget.duplicates.forEach((d) {
                if (d.duplicateFiles.contains(e)) {
                  if (d.duplicateFiles.length > 2) {
                    d.duplicateFiles.remove(e);
                    print('did i called : $e');
                  } else {
                    print('why am i called : $e');
                    toRemove.add(d);
                  }
                }
              });
              setState(() {
                if (toRemove.length > 0) {
                  toRemove.forEach((element) {
                    widget.duplicates.remove(element);
                  });
                }
                selectedFiles.clear();
              });
              String message = paths.length == 1
                  ? 'تم حذف الصورة المحددة'
                  : 'تم حذف الصور المحددة';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            });
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Container(
              margin: EdgeInsets.all(50),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  for (var i = 0; i < duplicates.length; i++)
                    InkWell(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(
                              duplicates[i],
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () => {},
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
