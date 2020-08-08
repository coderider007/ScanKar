import 'dart:io';

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
                      child: Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.share),
                                    onPressed: () {
                                      showToast("Not implemented...",
                                          gravity: Toast.BOTTOM);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.picture_as_pdf),
                                    onPressed: () {
                                      showToast("Not implemented...",
                                          gravity: Toast.BOTTOM);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Navigator.of(context).pop();
                                      Navigator.pushNamed(
                                        context,
                                        Constants.ROUTE_PAGES_IN_FILE,
                                        arguments: fileDetails.directory,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      delteDirectory(fileDetails.directory);
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

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
