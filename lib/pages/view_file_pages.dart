import 'dart:io';

import '../constants.dart';
import '../data/file_details.dart';
import '../services/file_storage.dart';
import 'package:flutter/material.dart';

class ViewFilePages extends StatefulWidget {
  ViewFilePages(this.directory);

  final Directory directory;

  @override
  _ViewFilePagesState createState() => _ViewFilePagesState(this.directory);
}

class _ViewFilePagesState extends State<ViewFilePages> {
  _ViewFilePagesState(this.directory);

  List<FileDetails> allFiles;
  final Directory directory;
  final FileStorageService _fileStorageService = FileStorageService.instance;
  //final String fileName = _fileStorageService.getFileName(directory.path);

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

  // void _backPressed(BuildContext context) async {
  //   setState(() {
  //     Navigator.of(context).pop();
  //   });
  // }

  Future<bool> _onDeletePressed(File file) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            titlePadding: EdgeInsets.only(bottom: 8, top: 4),
            title: Center(child: Text('Are you sure?')),
            content: Text(
              'Do you want delete this page?',
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "NO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              FlatButton(
                onPressed: () =>
                    {Navigator.of(context).pop(false), deleteFile(file)},
                child: Text(
                  "YES",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateListItems(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // final File atOldIndex = allFiles[oldIndex].file;
    // final File atNewIndex = allFiles[newIndex].file;

    final FileDetails item = allFiles.removeAt(oldIndex);
    allFiles.insert(newIndex, item);
    // _fileStorageService.swapFileNames(atOldIndex, atNewIndex);
    await _fileStorageService.renameFiles(allFiles.map((e) => e.file).toList());

    setState(() {
      allFiles = allFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_fileStorageService.getFileName(directory.path)),
      ),
      //drawer: CustomDrawer(),
      body: allFiles != null && allFiles.length > 0
          ? Center(
              child: Container(
                // height: 300,
                width: 200,
                // padding: EdgeInsets.all(8),
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) async {
                    await _updateListItems(oldIndex, newIndex);
                  },
                  children: List.generate(
                    allFiles.length,
                    (index) {
                      FileDetails fileDetails = allFiles[index];
                      return InkWell(
                        key: ValueKey("value$index"),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Constants.ROUTE_VIEW_PAGE,
                            arguments: fileDetails.file,
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          shadowColor: Colors.grey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Image.file(
                                  fileDetails.file,
                                  // width: MediaQuery.of(context).size.width / 2,
                                  // width: 150.0,
                                  // height: 180.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        // "Page " +
                                        //     _fileStorageService.getFileName(
                                        //         fileDetails.file.path),
                                        'Page ' + (index + 1).toString(),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () =>
                                          _onDeletePressed(fileDetails.file),
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
                ),
              ),
            )
          : Container(
              child: Center(
                child: Text('No Files!'),
              ),
            ),
    );
  }
}
