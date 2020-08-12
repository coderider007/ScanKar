import 'dart:io';

class FileDetails {
  FileDetails(this.file, this.name, this.modified, {this.directory});

  Directory directory;
  File file;
  DateTime modified;
  String name;
}
