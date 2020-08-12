import 'package:ScanKar/custom/filters/image_filters.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants.dart';
import '../custom/custom_drawer.dart';
import '../services/file_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_crop/image_crop.dart';

import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

enum AppState { ready, picked, cropped, edited, saved }
enum AppAction { pick_gallery, pick_camera, crop, edit, addmore, done }
final GlobalKey _globalKey = GlobalKey<CropState>();
final FileStorageService _fileStorageService = FileStorageService.instance;

class _ScanPageState extends State<ScanPage> {
  final cropKey = GlobalKey<CropState>();
  List<Uint8List> filesInAlbum = List();
  File imageFile;
  AppState state;
  ImageSource currentImageSource;
  var flt = presetFiltersList;
  List<Filter> _defaultFiltersList = [
    NoFilter(),
    InkwellFilter(),
    MyBrightnessFilter(),
    MyGreyscaleFilter()
  ];

  @override
  void initState() {
    super.initState();
    state = AppState.ready;
  }

  buttonOnPress(AppAction appAction) {
    switch (state) {
      case AppState.ready:
        //case AppState.addmore:
        if (appAction == AppAction.pick_camera) {
          _pickImage(ImageSource.camera);
        } else if (appAction == AppAction.pick_gallery) {
          _pickImage(ImageSource.gallery);
        } else {
          showToast("Unknow state and action combination",
              gravity: Toast.BOTTOM);
        }
        break;
      case AppState.picked:
        if (appAction == AppAction.crop) {
          _cropImage();
        } else {
          showToast("Unknow state and action combination",
              gravity: Toast.BOTTOM);
        }
        break;
      case AppState.cropped:
        if (appAction == AppAction.edit) {
          _editImage();
        } else {
          showToast("Unknow state and action combination",
              gravity: Toast.BOTTOM);
        }
        break;
      case AppState.edited:
        if (appAction == AppAction.addmore) {
          _addImage();
          _pickImage(currentImageSource);

          // setState(() {
          //   state = AppState.addmore;
          // });
        } else if (appAction == AppAction.done) {
          //_addImage();
          _saveAllImages();
        } else {
          showToast("Unknow state and action combination",
              gravity: Toast.BOTTOM);
        }
        break;
      case AppState.saved:
        if (appAction == AppAction.done) {
          _clearImage();
        } else {
          showToast("Unknow state and action combination",
              gravity: Toast.BOTTOM);
        }
        break;
      default:
        showToast("Unknow state", gravity: Toast.BOTTOM);
    }
  }

  List<Widget> _buildButtons() {
    switch (state) {
      case AppState.ready:
        return [
          FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () {
              buttonOnPress(AppAction.pick_gallery);
            },
            heroTag: 'imagePickFromGalary',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                buttonOnPress(AppAction.pick_camera);
              },
              heroTag: 'imagePickFromCamera',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera),
            ),
          )
        ];
      case AppState.picked:
        return [
          FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () {
              buttonOnPress(AppAction.crop);
            },
            child: Icon(Icons.crop),
          )
        ];
      case AppState.cropped:
        return [
          FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () {
              buttonOnPress(AppAction.edit);
            },
            child: Icon(Icons.edit),
          )
        ];
      case AppState.edited:
        return [
          FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () {
              buttonOnPress(AppAction.done);
            },
            heroTag: 'imageDone',
            tooltip: 'Done',
            child: const Icon(Icons.done),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                buttonOnPress(AppAction.addmore);
              },
              heroTag: 'imageAddMore',
              tooltip: 'Add More',
              child: const Icon(Icons.add),
            ),
          ),
        ];
      case AppState.saved:
        return [
          FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: () {
              buttonOnPress(AppAction.done);
            },
            child: Icon(Icons.done_all),
          )
        ];
      default:
        return [Container()];
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<Null> _pickImage(ImageSource imageSource) async {
    if (imageSource != null) {
      if (imageSource == ImageSource.gallery) {
        //imageFile = await ImagePicker.pickImage(source: imageSource);
        ImagePicker _imagePicker = new ImagePicker();
        PickedFile pikedFile = await _imagePicker.getImage(source: imageSource);
        if (pikedFile != null) imageFile = File(pikedFile.path);
      } else if (imageSource == ImageSource.camera) {
        // Platform messages may fail, so we use a try/catch PlatformException.
        try {
          if (await Permission.camera.request().isGranted) {
            String imagePath = await EdgeDetection.detectEdge;
            print("image path = " + imagePath);
            imageFile = File(imagePath);
          } else if (await Permission.speech.isPermanentlyDenied) {
            openAppSettings();
          }
        } on PlatformException {}

        // If the widget was removed from the tree while the asynchronous platform
        // message was in flight, we want to discard the reply rather than calling
        // setState to update our non-existent appearance.
        if (!mounted) return;
      }
    } else {
      showToast('Image Source can not be NULL');
    }

    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
        currentImageSource = imageSource;
      });
    }
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    // final sampledFile = await ImageCrop.sampleImage(
    //   file: imageFile,
    //   preferredSize: (2000 / scale).round(),
    // );
    final sampledFile = await ImageCrop.sampleImage(
      file: imageFile,
      preferredWidth: (1024 / scale).round(),
      preferredHeight: (4096 / scale).round(),
    );

    final croppedFile = await ImageCrop.cropImage(
      file: sampledFile,
      area: area,
    );

    sampledFile.delete();

    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _editImage() async {
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text("Apply Filter"),
          image: imageLib.decodeImage(imageFile.readAsBytesSync()),
          filters: _defaultFiltersList,
          filename: imageFile.path,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
        state = AppState.edited;
      });
      print(imageFile.path);
    }
  }

  Future<void> _addImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData.buffer.asUint8List();
    filesInAlbum.add(bytes);

    setState(() {
      this.filesInAlbum = filesInAlbum;
      imageFile = null;
    });

    showToast("Page added", gravity: Toast.BOTTOM);
  }

  void _saveAllImages() async {
    await _addImage();
    var folderName = generateFolderName();
    for (int i = 0; i < filesInAlbum.length; i++) {
      await _fileStorageService.createFileToDir(
          (i + 1), filesInAlbum[i], folderName);
    }
    setState(() {
      imageFile = null;
      filesInAlbum.clear();
      state = AppState.saved;
    });
    showToast("Saved", gravity: Toast.BOTTOM);
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.ready;
      currentImageSource = null;
    });
    showToast("Cleared", gravity: Toast.BOTTOM);
  }

  String generateFolderName() {
    return DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());
    // return DateFormat.yMEd().add_jms().format(DateTime.now());
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle),
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: imageFile != null
            ? RepaintBoundary(
                key: _globalKey,
                child: state == AppState.picked
                    ? Crop.file(imageFile, key: cropKey)
                    : Image.file(imageFile),
              )
            : Container(
                child: Text('Click or Select image!'),
              ),
      ),
      floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end, children: _buildButtons()),
    );
  }
}
