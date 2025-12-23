import 'package:flutter/material.dart';

class DropdownButtonModel {
  int? dropOrder;
  String? dropText;
  String? dropImage;
  IconData? dropIcon;
  dynamic dropValue;

  DropdownButtonModel(
      {this.dropText, this.dropOrder, this.dropValue, this.dropImage});
}
