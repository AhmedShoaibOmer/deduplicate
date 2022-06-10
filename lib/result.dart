import 'dart:io';

import 'package:deduplicator/deduplicator.dart';
import 'package:flutter/material.dart';

import 'duplicate.dart';
import 'duplicate_images.dart';
import 'no_duplicate_files.dart';
import 'scanning_screen.dart';

class Result extends StatefulWidget {
  const Result({Key? key}) : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Object?>?>(
        future: Deduplicator.getDuplicateFilesF(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Object?>?> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const NoDuplicateFiles();
            } else {
              print('snapshot has data');

              List<Duplicate> duplicates = [];

              snapshot.data!.forEach((o) {
                List<File> files = [];
                (o as List<Object?>).forEach((element) {
                  File file = File((element as String?)!);
                  if (file.existsSync()) {
                    files.add(file);
                  }
                });
                if (files.isNotEmpty) {
                  duplicates.add(Duplicate(files));
                }
              });
              if (duplicates.isEmpty) {
                return const NoDuplicateFiles();
              } else {
                return DuplicateImages(
                  duplicates,
                  key: GlobalKey(),
                );
              }
            }
          } else {
            return Scanning();
          }
        });
    //   return StreamBuilder(
    //       stream: Deduplicator.duplicateFilesStream,
    //       builder:
    //           (BuildContext context, AsyncSnapshot<List<Object?>?> snapshot) {
    //         if (!snapshot.hasData) {
    //           return Scanning();
    //         } else if (snapshot.data!.isEmpty) {
    //           return NoDuplicateFiles();
    //         } else {
    //             print('snapshot has data');

    //           List<Duplicate> duplicates = [];

    //           snapshot.data!.forEach((o) {
    //             List<File> files = [];
    //             (o as List<Object?>).forEach((element) {
    //               files.add(File((element as String?)!));
    //             });
    //             duplicates.add(Duplicate(files));
    //           });
    //           return DuplicateImages(duplicates);
    //         }
    //       });
    // }
  }
}
