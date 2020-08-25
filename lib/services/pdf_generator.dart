import 'dart:io';

import 'package:ScanKar/services/file_storage.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:images_to_pdf/images_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
// import 'package:toast/toast.dart';

import '../constants.dart';

class PdfGeneratorService {
  static const int DO_NOTHING = 0;
  static const int RENAME = 1;
  static const int OVER_WRITE = 2;
  static const int KEEP_BOTH = 3;

  PdfGeneratorService._privateConstructor();

  static final PdfGeneratorService instance =
      PdfGeneratorService._privateConstructor();

  FileStorageService _fileStorageService = FileStorageService.instance;

  Future<File> getIfExists(Directory filesDir) async {
    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      if (await Permission.storage.request().isGranted) {
        // showToast(context, 'Permissions Granted!');
        if (Platform.isAndroid) {
          var extDir = await ExtStorage.getExternalStoragePublicDirectory(
              ExtStorage.DIRECTORY_DOWNLOADS);
          downloadsDirectory = Directory(extDir + '/ScanKar');
          // dir = (await getExternalStorageDirectory()).path;
        } else if (Platform.isIOS) {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        // downloadsDirectory.createSync(recursive: true);
        // downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
        // downloadsDirectory = await getExternalStorageDirectory();
      } else if (await Permission.speech.isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        //showToast(context, 'No Permissions Granted!');
        openAppSettings();
      }

      // downloadsDirectory = await getExternalStorageDirectory();
    } on PlatformException {
      print('Could not get the downloads directory');
      downloadsDirectory = await getApplicationDocumentsDirectory();
    }
    var fileName = path.basename(filesDir.path);

    File output = File(path.join(downloadsDirectory.path, fileName + '.pdf'));
    return output;
  }

  Future<File> createPdf(BuildContext context, Directory filesDir) async {
    File output;
    try {
      Directory downloadsDirectory;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        if (await Permission.storage.request().isGranted) {
          // showToast(context, 'Permissions Granted!');
          if (Platform.isAndroid) {
            var extDir = await ExtStorage.getExternalStoragePublicDirectory(
                ExtStorage.DIRECTORY_DOWNLOADS);
            downloadsDirectory = Directory(extDir + '/ScanKar');
            // dir = (await getExternalStorageDirectory()).path;
          } else if (Platform.isIOS) {
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }

          // downloadsDirectory.createSync(recursive: true);
          // downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
          // downloadsDirectory = await getExternalStorageDirectory();
        } else if (await Permission.speech.isPermanentlyDenied) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          //showToast(context, 'No Permissions Granted!');
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
      if (await output.exists()) {
        int userChoice = DO_NOTHING;
        do {
          userChoice = await _overriteDialog(context, output);
        } while (userChoice == DO_NOTHING);

        if (userChoice == KEEP_BOTH) {
          output = File(path.join(downloadsDirectory.path,
              fileName + '_' + _fileStorageService.timeStamp() + '.pdf'));
        } else if (userChoice == RENAME ||
            userChoice == null ||
            userChoice == DO_NOTHING) {
          return Future.value(null);
        } else if (userChoice == OVER_WRITE) {
          // do nothing
        }
      }
      output.createSync(recursive: true);
      print(output.toString());
      await ImagesToPdf.createPdf(
        pages: images
            .map(
              (file) => PdfPage(
                imageFile: file,
                //size: Size(1920, 1080),
                compressionQuality: 1.0,
              ),
            )
            .toList(),
        output: output,
      );
      var _pdfStat = await output.stat();
      //var _status = 'PDF (${_pdfStat.size ~/ 1024}kb) saved to Downloads';
      print(_pdfStat.toString());
      //print(_status);
      showSnackBar(context, output);
    } catch (e) {}

    return output;
  }

  Future<int> _overriteDialog(context, File file) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            //titlePadding: EdgeInsets.only(bottom: 8, top: 4),
            //title: Center(child: Text('Are you sure?')),
            content: Text(
              'File with name ' +
                  _fileStorageService.getFileName(file.path) +
                  ' already exists!',
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(RENAME),
                child: Text(
                  'Rename',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(KEEP_BOTH),
                child: Text(
                  'Keep Both',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(OVER_WRITE),
                child: Text(
                  'Overwrite',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        DO_NOTHING;
  }

  void showSnackBar(context, File file) async {
    final scaffold = Scaffold.of(context);
    var _pdfStat = await file.stat();
    var _downloadedMsg = ' size ${_pdfStat.size ~/ 1024}kb saved to downloads';
    scaffold.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: RichText(
          text: TextSpan(
            //style: defaultStyle,
            children: <TextSpan>[
              TextSpan(
                  text: _fileStorageService.getFileName(file.path),
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      //Navigator.of(context).pushNamed(routeName);
                      Navigator.pushNamed(
                        context,
                        Constants.ROUTE_VIEW_PDF,
                        arguments: file,
                      );
                    }),
              TextSpan(text: _downloadedMsg),
            ],
          ),
        ),
      ),
    );
    //Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
