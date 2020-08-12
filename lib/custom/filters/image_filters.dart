import 'dart:typed_data';

import 'package:photofilters/filters/color_filters.dart';
import 'package:photofilters/filters/image_filters.dart';
import 'package:photofilters/filters/subfilters.dart';
import 'package:photofilters/models.dart';
import 'package:photofilters/utils/image_filter_utils.dart'
    as image_filter_utils;
import 'package:photofilters/utils/color_filter_utils.dart'
    as color_filter_utils;

class MyBrightnessFilter extends ColorFilter {
  MyBrightnessFilter() : super(name: "Enhance Colors") {
    this.addSubFilter(BrightnessSubFilter(0.3));
    //this.addSubFilter(HueRotationSubFilter(30));
  }
}

class MyGreyscaleFilter extends ColorFilter {
  MyGreyscaleFilter() : super(name: "Grey Scale") {
    this.addSubFilter(MyGreyScaleSubFilter());
    this.addSubFilter(HueRotationSubFilter(30));
  }
}

class MyGreyScaleSubFilter extends ColorSubFilter with ImageSubFilter {
  MyGreyScaleSubFilter();

  ///Apply the [MyGreyScaleSubFilter] to an Image.
  @override
  void apply(Uint8List pixels, int width, int height) =>
      image_filter_utils.grayscale(pixels);

  ///Apply the [BrightnessSubFilter] to a color.
  @override
  RGBA applyFilter(RGBA color) => color_filter_utils.grayscale(color);
}
