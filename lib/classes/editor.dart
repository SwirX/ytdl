import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class VideoEditor {
  static Future<void> mergeAudioWithVideo(
      String videoPath, String audioPath, String outputPath) async {
    final command =
        '-y -i "$videoPath" -i "$audioPath" -c:v copy -c:a aac "$outputPath"';

    print("command: $command");

    final session = await FFmpegKit.execute(command);

    final returnCode = await session.getReturnCode();
    if (returnCode!.isValueSuccess()) {
      print('Successfully merged video and audio');
    } else {
      print('Failed to merge video and audio');
    }
    final out = outputPath.split("/");
    out.removeLast();
    final logPath = "${out.join("/")}/logs.txt";
    print("logpath: $logPath");
    await File(logPath).create()
      ..writeAsString(jsonEncode(
          (await session.getLogs()).map((e) => e.getMessage()).toList()));
  }
}
