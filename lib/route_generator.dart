import 'dart:io';

import 'package:ScanKar/constants.dart';
import 'package:ScanKar/pages/home_page.dart';
import 'package:ScanKar/pages/pdf_viewer.dart';
import 'package:ScanKar/pages/view_pages.dart';

import 'pages/scan_page.dart';
import 'pages/home_page.dart';
import 'pages/view_file_pages.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;

    switch (settings.name) {
      case Constants.ROUTE_HOME:
        return MaterialPageRoute(builder: (context) => HomePage());
      case Constants.ROUTE_SCAN_NEW:
        return MaterialPageRoute(builder: (_) => ScanPage());
      case Constants.ROUTE_PAGES_IN_FILE:
        // Cast the arguments to the correct type: ScreenArguments.
        final Directory directory = settings.arguments;
        return MaterialPageRoute(
            builder: (context) => ViewFilePages(directory));
      case Constants.ROUTE_VIEW_PAGE:
        final File page = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewPages(page));
      case Constants.ROUTE_VIEW_PDF:
        final File pdfFile = settings.arguments;
        return MaterialPageRoute(builder: (context) => ViewPDF(pdfFile));
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Error"),
        ),
        body: Center(
          child: Text("ERROR"),
        ),
      );
    });
  }
}
