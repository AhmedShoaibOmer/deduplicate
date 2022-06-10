import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Deduplicator {
  static const MethodChannel _methodChannel =
      MethodChannel('deduplicator/method');
  static const EventChannel _eventChannel = EventChannel('deduplicator/event');

  static Stream<List<Object?>?>? _stream;
  static Stream<List<Object?>?>? get duplicateFilesStream {
    
    _stream = _eventChannel.receiveBroadcastStream().map<List<Object?>>((event) {
      print('Deduplicator Dart : ${event.toString()}');
      return event;
    });
    print('Stream' + _stream.toString());
    return _stream;
  }

  static void getDuplicateFiles() async {
    _methodChannel.invokeMethod('getDuplicateFiles');
  }

  static Future<List<Object?>?> getDuplicateFilesF() async {
    return _methodChannel.invokeMethod('getDuplicateFilesF');
  }

  static Future<String?> get platformVersion async {
    final String? version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }
}
