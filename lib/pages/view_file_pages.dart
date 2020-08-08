import 'dart:io';

import '../constants.dart';
import '../custom/custom_drawer.dart';
import '../data/file_details.dart';
import '../services/file_storage.dart';
import 'package:flutter/material.dart';

class ViewFilePages extends StatefulWidget {
  final Directory directory;
  ViewFilePages(this.directory);

  @override
  _ViewFilePagesState createState() => _ViewFilePagesState(this.directory);
}

class _ViewFilePagesState extends State<ViewFilePages> {
  final Directory directory;
  final FileStorageService _fileStorageService = FileStorageService.instance;
  List<FileDetails> allFiles;
  _ViewFilePagesState(this.directory);

  @override
  void initState() {
    super.initState();
    // allFiles =
    loadImageList();
  }

  void deleteFile(File file) {
    _fileStorageService.deleteFile(file).then((value) => loadImageList());
  }

  Future<void> loadImageList() async {
    List<FileDetails> tempAllFiles = List();
    if (directory != null) {
      List<File> files =
          await _fileStorageService.getAllFilesFromDir(directory);
      files.forEach((file) => tempAllFiles.add(FileDetails(file,
          _fileStorageService.getFileName(file.path), file.lastModifiedSync(),
          directory: directory)));

      if (tempAllFiles != null) {
        setState(() {
          allFiles = tempAllFiles;
        });
      }
    }
    // return allFiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle + ' - Current Pages'),
      ),
      drawer: CustomDrawer(),
      body: allFiles != null && allFiles.length > 0
          ? ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                _updateListItems(oldIndex, newIndex);
              },
              children: List.generate(
                allFiles.length,
                (index) {
                  FileDetails fileDetails = allFiles[index];
                  return Container(
                    key: ValueKey("value$index"),
                    padding: EdgeInsets.fromLTRB(50, 20, 50, 10),
                    child: Card(
                      shadowColor: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(
                          //     (index + 1).toString(),
                          //     textAlign: TextAlign.left,
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Image.file(
                              fileDetails.file,
                              // width: MediaQuery.of(context).size.width / 2,
                              width: 300.0,
                              height: 380.0,
                              fit: BoxFit.fill,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Text(fileDetails.name),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Icon(Icons.share),
                                // Icon(Icons.file_download),
                                // Icon(Icons.edit),
                                // Text(fileDetails.name),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                    'Page ' + (index + 1).toString(),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deleteFile(fileDetails.file);
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : Container(
              child: Center(
                child: Text('No Files!'),
              ),
            ),
    );
  }

  void _updateListItems(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // final File atOldIndex = allFiles[oldIndex].file;
    // final File atNewIndex = allFiles[newIndex].file;

    final FileDetails item = allFiles.removeAt(oldIndex);
    allFiles.insert(newIndex, item);
    // _fileStorageService.swapFileNames(atOldIndex, atNewIndex);
    _fileStorageService.renameFiles(allFiles.map((e) => e.file).toList());

    setState(() {
      allFiles = allFiles;
    });
  }
}