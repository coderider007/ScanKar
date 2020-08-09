import 'dart:io';

import 'package:ScanKar/custom/custom_list_tile.dart';
import 'package:ScanKar/services/pdf_generator.dart';

import '../constants.dart';
import '../data/file_details.dart';
import '../custom/custom_drawer.dart';
import '../services/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<FileDetails>> allFiles;
  FileStorageService _fileStorageService = FileStorageService.instance;
  PdfGeneratorService _pdfGeneratorService = PdfGeneratorService.instance;

  @override
  void initState() {
    super.initState();
    allFiles = loadImageList();
  }

  void delteDirectory(Directory directory) {
    _fileStorageService.deleteDir(directory).then((value) => {
          setState(() {
            allFiles = loadImageList();
            showToast("Not implemented...", gravity: Toast.BOTTOM);
          })
        });
  }

  void renameDirectory(Directory directory, String name) {
    _fileStorageService.renameDir(directory, name).then((value) => {
          setState(() {
            allFiles = loadImageList();
            showToast("Not implemented...", gravity: Toast.BOTTOM);
          })
        });
  }

  Future<List<FileDetails>> loadImageList() async {
    List<FileDetails> tempAllFiles = List();
    Directory dir = await _fileStorageService.getDirectory();
    List<Directory> subDirs = await _fileStorageService.getSubDirs(dir);
    for (var i = 0; i < subDirs.length; i++) {
      File firstFile =
          await _fileStorageService.getFirstFileFromDir(subDirs[i]);
      if (firstFile != null) {
        tempAllFiles.add(FileDetails(
            firstFile,
            _fileStorageService.getFileName(subDirs[i].path),
            firstFile.lastModifiedSync(),
            directory: subDirs[i]));
      }
    }

    return tempAllFiles;

    // if (tempAllFiles.length > 0) {
    //   setState(() {
    //     allFiles = tempAllFiles;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle + ' - Home'),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: FutureBuilder(
          builder: (context, projectSnap) {
            if (projectSnap.hasData) {
              //print('project snapshot data is: ${projectSnap.data}');
              return Container(
                child: ListView.builder(
                  itemCount: projectSnap.data.length,
                  itemBuilder: (context, index) {
                    FileDetails fileDetails = projectSnap.data[index];
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: GestureDetector(
                        onLongPress: () {
                          showFileOptionsDialog(context, fileDetails);
                        },
                        child: Stack(
                          children: <Widget>[
                            Card(
                              child: ListTile(
                                leading: Image.file(
                                  fileDetails.file,
                                  // width: MediaQuery.of(context).size.width / 2,
                                  width: 50.0,
                                  height: 80.0,
                                  fit: BoxFit.fill,
                                ),
                                title: Text(fileDetails.name),
                                subtitle: Text('Last modified at ' +
                                    fileDetails.modified.toString()),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                ),
                                onPressed: () {
                                  showFileOptionsDialog(context, fileDetails);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Container(
                child: Center(
                  child: Text('No Files!'),
                ),
              );
            }
          },
          future: allFiles,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          // Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Constants.ROUTE_SCAN_NEW);
        },
        heroTag: 'imageScanNew',
        tooltip: 'Scan new document',
        child: const Icon(Icons.add),
      ),
    );
  }

  showFileOptionsDialog(BuildContext context, FileDetails fileDetails) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text("My title"),
      content: Container(
        width: 250,
        height: 255,
        child: Column(
          children: <Widget>[
            CustomListTile(Icons.share, "Share", () {
              Navigator.of(context).pop();
              showToast("Not implemented...", gravity: Toast.BOTTOM);
            }),
            CustomListTile(Icons.picture_as_pdf, "Download as PDF", () {
              Navigator.of(context).pop();
              _pdfGeneratorService.createPdf(context, fileDetails.directory);
              showToast("Downloading to as PDF...",
                  duration: 3, gravity: Toast.BOTTOM);
            }),
            CustomListTile(Icons.open_in_new, "Edit", () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                Constants.ROUTE_PAGES_IN_FILE,
                arguments: fileDetails.directory,
              );
            }),
            CustomListTile(Icons.edit, "Rename", () {
              Navigator.of(context).pop();
              showFileRenameDialog(context, fileDetails);
            }),
            CustomListTile(Icons.delete, "Delete", () {
              Navigator.of(context).pop();
              delteDirectory(fileDetails.directory);
            }),
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showFileRenameDialog(BuildContext context, FileDetails fileDetails) {
    final fileNameController = TextEditingController(text: fileDetails.name);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Rename File'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: fileNameController,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
            fileNameController.dispose();
          },
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
            _fileStorageService.renameDir(
                fileDetails.directory, fileNameController.text);
            showToast('Renamed');
          },
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
