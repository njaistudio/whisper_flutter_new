/*
 * Copyright (c) 田梓萱[小草林] 2021-2024.
 * All Rights Reserved.
 * All codes are protected by China's regulations on the protection of computer software, and infringement must be investigated.
 * 版权所有 (c) 田梓萱[小草林] 2021-2024.
 * 所有代码均受中国《计算机软件保护条例》保护，侵权必究.
 */

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";

/// Available whisper models
enum WhisperModel {
  // no model
  none(""),

  /// tiny model for all languages
  tiny("tiny"),

  /// base model for all languages
  base("base"),

  /// small model for all languages
  small("small"),

  /// medium model for all languages
  medium("medium"),

  /// large model for all languages
  largeV1("large-v1"),
  largeV2("large-v2");

  const WhisperModel(this.modelName);

  /// Public name of model
  final String modelName;

  /// Get local path of model file
  String getPath(String dir) {
    return "$dir/ggml-$modelName.bin";
  }
}

/// Download [model] to [destinationPath]
Future<String> downloadModel(
    {required WhisperModel model,
    required String destinationPath,
    String? downloadHost,
    ProgressCallback? onProgress}) async {
  if (kDebugMode) {
    debugPrint("Download model ${model.modelName}");
  }

  String modelUrl;

  if (downloadHost == null || downloadHost.isEmpty) {
    /// Huggingface url to download model
    modelUrl = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${model.modelName}.bin";
  } else {
    modelUrl = "$downloadHost/ggml-${model.modelName}.bin";
  }
  final savePath = "$destinationPath/ggml-${model.modelName}.bin";
  final dio = Dio();

  try {
    await dio.download(
      modelUrl,
      savePath,
      onReceiveProgress: (received, total) {
        onProgress?.call(received, total);
        if (total != -1) {
          final percent = (received / total * 100).toStringAsFixed(0);
          if (kDebugMode) {
            print("Progressing: $percent% ($received / $total bytes)");
          }
        } else {
          if (kDebugMode) {
            print("Received: $received bytes");
          }
        }
      },
    );

    if (kDebugMode) {
      print("✅ Done: $savePath");
    }
  } catch (e) {
    if (kDebugMode) {
      print("❌ Error when download file: $e");
    }
  }
  return savePath;
}
