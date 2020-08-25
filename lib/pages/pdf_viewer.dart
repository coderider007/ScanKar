import 'dart:io';

import '../services/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class ViewPDF extends StatefulWidget {
  ViewPDF(this.pdfFile, {Key key}) : super(key: key);

  final File pdfFile;

  @override
  _ViewPDFState createState() => _ViewPDFState(pdfFile);
}

class _ViewPDFState extends State<ViewPDF> {
  _ViewPDFState(this.pdfFile);
  final FileStorageService _fileStorageService = FileStorageService.instance;
  int _actualPageNumber = 1, _allPagesCount = 0;
  PdfController _pdfController;
  File pdfFile;

  @override
  void initState() {
    _pdfController = PdfController(
      document: PdfDocument.openFile(pdfFile.path),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_fileStorageService.getFileName(pdfFile.path)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () {
              _pdfController.previousPage(
                curve: Curves.ease,
                duration: Duration(milliseconds: 100),
              );
            },
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              '$_actualPageNumber/$_allPagesCount',
              style: TextStyle(fontSize: 20),
            ),
          ),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              _pdfController.nextPage(
                curve: Curves.ease,
                duration: Duration(milliseconds: 100),
              );
            },
          )
        ],
      ),
      body: PdfView(
        documentLoader: Center(child: CircularProgressIndicator()),
        pageLoader: Center(child: CircularProgressIndicator()),
        controller: _pdfController,
        onDocumentLoaded: (document) {
          setState(() {
            _actualPageNumber = 1;
            _allPagesCount = document.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            _actualPageNumber = page;
          });
        },
      ),
    );
  }
}
