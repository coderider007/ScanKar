import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:toast/toast.dart';
import 'package:ScanKar/custom/custom_list_tile.dart';
import 'package:ScanKar/services/pdf_generator.dart';
import 'package:intl/intl.dart';

import '../constants.dart';
import '../data/file_details.dart';
import '../custom/custom_drawer.dart';
import '../services/file_storage.dart';

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
            showToast("Deleted.", gravity: Toast.BOTTOM);
          })
        });
  }

  void renameDirectory(Directory directory, String name) {
    _fileStorageService.renameDir(directory, name).then((value) => {
          setState(() {
            allFiles = loadImageList();
            showToast("Renamed to '$name'", gravity: Toast.BOTTOM);
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
    tempAllFiles.sort((a, b) => compare(a.modified, b.modified));

    return tempAllFiles;
  }

  int compare(DateTime a, DateTime b) {
    if (a == b || a.isAtSameMomentAs(b)) return 0;
    return a.isAfter(b) ? -1 : 1;
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
            CustomListTile(Icons.open_in_new, "Open", () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                Constants.ROUTE_PAGES_IN_FILE,
                arguments: fileDetails.directory,
              ).then(
                (value) => {
                  setState(() {
                    allFiles = loadImageList();
                  })
                },
                // onError: (error) => {
                //       setState(() {
                //         allFiles = loadImageList();
                //       })
                //     }
              );
            }),
            CustomListTile(Icons.share, "Share", () {
              Navigator.of(context).pop();
              _shareFile(context, fileDetails.directory);
              //showToast("PDF shared!", gravity: Toast.BOTTOM);
            }),
            CustomListTile(Icons.picture_as_pdf, "Download as PDF", () {
              Navigator.of(context).pop();
              _pdfGeneratorService.createPdf(context, fileDetails.directory);
              // showToast("Downloaded as PDF...",
              //     duration: 3, gravity: Toast.BOTTOM);
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
            _renameDir(context, fileDetails.directory, fileNameController.text);
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

  void _renameDir(
      BuildContext context, Directory directory, String name) async {
    await _fileStorageService.renameDir(directory, name);
    showToast('Renamed', gravity: Toast.BOTTOM);
    setState(() {
      allFiles = loadImageList();
    });
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  void _shareFile(BuildContext context, Directory directory) async {
    File file = await _pdfGeneratorService.getIfExists(directory);

    if (!file.existsSync()) {
      file = await _pdfGeneratorService.createPdf(context, directory);
    }

    await FlutterShare.shareFile(
      title: 'Share',
      text: 'Share PDF to ',
      filePath: file.path,
    );
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
            if (projectSnap.hasData && projectSnap.data.length > 0) {
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
                        onTap: () {
                          showFileOptionsDialog(context, fileDetails);
                        },
                        onDoubleTap: () {
                          Navigator.pushNamed(
                            context,
                            Constants.ROUTE_PAGES_IN_FILE,
                            arguments: fileDetails.directory,
                          ).then(
                            (value) => {
                              setState(() {
                                allFiles = loadImageList();
                              })
                            },
                            // onError: (error) => {
                            //       setState(() {
                            //         allFiles = loadImageList();
                            //       })
                            //     }
                          );
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
                                subtitle: Text('Create on : ' +
                                    DateFormat.yMMMd()
                                        .add_jms()
                                        .format(fileDetails.modified)),
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
                width: MediaQuery.of(context).size.width / 1.2,
                child: Center(
                  child: Text(
                      'No scanned file exists. Click the plus icon to create new file!'),
                ),
              );
            }
          },
          future: allFiles,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constants.MAIN_COLOR,
        onPressed: () {
          //Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Constants.ROUTE_SCAN_NEW).then(
                (value) => {
                  setState(() {
                    allFiles = loadImageList();
                  })
                },
                // onError: (error) => {
                //       setState(() {
                //         allFiles = loadImageList();
                //       })
                //     }
              );
        },
        heroTag: 'imageScanNew',
        tooltip: 'Scan new document',
        child: const Icon(Icons.add),
      ),
    );
  }
}
