import 'dart:io';

import 'package:ScanKar/services/file_storage.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:images_to_pdf/images_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

class PdfGeneratorService {
  PdfGeneratorService._privateConstructor();

  static final PdfGeneratorService instance =
      PdfGeneratorService._privateConstructor();

  FileStorageService _fileStorageService = FileStorageService.instance;

  Future<File> createPdf(BuildContext context, Directory filesDir) async {
    File output;
    try {
      Directory downloadsDirectory;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        if (await Permission.storage.request().isGranted) {
          showToast(context, 'Permissions Granted!');
          downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
        } else if (await Permission.speech.isPermanentlyDenied) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          showToast(context, 'No Permissions Granted!');
          openAppSettings();
        }

        // downloadsDirectory = await getExternalStorageDirectory();
      } on PlatformException {
        print('Could not get the downloads directory');
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      List<File> images =
          await _fileStorageService.getAllFilesFromDir(filesDir);

      var fileName = path.basename(filesDir.path);

      output = File(path.join(downloadsDirectory.path, fileName + '.pdf'));
      print(output.toString());
      await ImagesToPdf.createPdf(
        pages: images
            .map(
              (file) => PdfPage(
                imageFile: file,
                //size: Size(1920, 1080),
                compressionQuality: 0.5,
              ),
            )
            .toList(),
        output: output,
      );
      var _pdfStat = await output.stat();
      var _status = 'PDF Generated (${_pdfStat.size ~/ 1024}kb)';
      print(_pdfStat.toString());
      print(_status);
      showToast(context, _status, duration: 3);
    } catch (e) {}

    return output;
  }

  void showToast(context, String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
