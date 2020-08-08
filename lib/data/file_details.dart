import 'dart:io';

class FileDetails {
  Directory directory;
  File file;
  String name;
  DateTime modified;

  FileDetails(this.file, this.name, this.modified, {this.directory});
}
