import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';

class FileStorageService {
  FileStorageService._privateConstructor();

  static final FileStorageService instance =
      FileStorageService._privateConstructor();

  Future<String> get _localPath async {
    Directory directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> getDirectory() async {
    Directory directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<List<Directory>> getSubDirs(Directory directory) async {
    return directory
        .listSync(recursive: false, followLinks: false)
        .where((element) => element is Directory)
        .map((element) => element as Directory)
        .toList();
  }

  Future<void> deleteDir(Directory directory) async {
    return directory.deleteSync(recursive: true);
  }

  Future<void> renameDir(Directory directory, String name) async {
    var files = await getAllFilesFromDir(directory);
    files.forEach((file) {
      File newFile = File(path.join(file.parent.parent.path, name) +
          '/' +
          path.basename(file.path));
      newFile.createSync(recursive: true);
      file.renameSync(newFile.path);
    });
    directory.deleteSync(recursive: true);
    // return directory.renameSync(path.join(path.basename(directory.path), name));
  }

  Future<void> deleteFile(File file) async {
    return file.deleteSync();
  }

  Future<List<File>> getAllFilesFromDir(Directory dir) async {
    return await dir.exists()
        ? dir
            .listSync()
            .where((element) => (element is File))
            .map((element) => (element as File))
            .toList()
        : List<File>();
  }

  Future<Directory> createNewDir(String dirName) async {
    final docPath = await _localPath;
    return Directory('$docPath/$dirName').create();
  }

  Future<File> getFirstFileFromDir(Directory dir) async {
    List<File> files = await dir.exists()
        ? dir
            .listSync()
            .where((element) => element is File)
            .map((element) => element as File)
            .where((element) => element.path.endsWith('.jpeg'))
            .toList()
        : List();

    return files.length > 0 ? files.first : null;
  }

  Future<File> saveFileToDir(File file, String dirName) async {
    final docPath = await _localPath;
    File newFile;
    if (await file.exists()) {
      //To get file name without extension
      //path.basenameWithoutExtension(file.path);
      //return file with file extension
      String fileName = path.basename(file.path);

      File tempFile =
          await File('$docPath/$dirName/$fileName').create(recursive: true);
      newFile = file.copySync(tempFile.path);
      file.deleteSync();
    } else {
      newFile = null;
    }
    return newFile;
  }

  Future<File> createFileToDir(
      int seqNum, Uint8List bytes, String dirName) async {
    final docPath = await _localPath;

    String fileName = seqNum.toString() + '.jpeg';
    // seqNum.toString() + '-' + new DateTime.now().toString() + '.jpeg';

    File tempFile =
        await File('$docPath/$dirName/$fileName').create(recursive: true);
    tempFile.writeAsBytesSync(bytes.toList(), flush: true);
    return tempFile;
  }

  Future<void> swapFileNames(File file1, File file2) async {
    String fileName1 = file1.path;
    String fileName2 = file2.path;

    File temp = file1.renameSync(path.dirname(file1.path) + '/temp.jpeg');
    file2.renameSync(fileName1);
    temp.renameSync(fileName2);
  }

  Future<void> renameFiles(List<File> files) async {
    List<File> tempFiles = List();
    for (int i = 0; i < files.length; i++) {
      File oldFile = files[i];
      File tempFile = oldFile.renameSync(
          path.dirname(oldFile.path) + '/' + (i + 1).toString() + '-temp.jpeg');
      tempFiles.add(tempFile);
    }
    for (int i = 0; i < tempFiles.length; i++) {
      File tempFile = tempFiles[i];
      tempFile.renameSync(
          path.dirname(tempFile.path) + '/' + (i + 1).toString() + '.jpeg');
    }
  }

  // Future<void> renameFileFrom(List<File> files, int index) async {
  //   for (int i = 0; i < files.length - 1; i++) {
  //     if (i < index) continue;
  //     String dirName = path.dirname(files[i].path);
  //     //String fileName2 = files[i + 1].path;

  //     File temp = files[i].renameSync(dirName + '/temp.jpeg');
  //     files[i + 1].renameSync(dirName + i.toString() + '.jpeg');
  //     temp.renameSync(fileName2);
  //   }
  // }

  String timeStamp() {
    return DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
    // return DateFormat.yMEd().add_jms().format(DateTime.now());
  }

  String getFileName(String filepath) {
    return path.basename(filepath);
  }

  String getFileNameWithoutExtension(String filepath) {
    return path.basenameWithoutExtension(filepath);
  }
}
