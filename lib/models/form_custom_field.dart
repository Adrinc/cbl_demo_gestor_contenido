import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FormCustomField {
  int? formId;
  int? fillId;
  int fieldId;
  String fieldName;
  String? fieldType;
  String? fieldIcon;
  IconData? fieldIconData;
  bool? fieldVisible;
  int? fieldOrder;
  List<String>? enumValues;
  bool? enumVisible;
  int? fieldValueId;
  String? fieldValue;
  List<String> fieldValues = [];
  TextEditingController textEditingController = TextEditingController();

  FormCustomField({
    this.formId,
    this.fillId,
    required this.fieldId,
    required this.fieldName,
    this.fieldType,
    this.fieldIcon,
    this.fieldIconData,
    this.fieldVisible,
    this.fieldOrder,
    this.enumValues,
    this.enumVisible,
    this.fieldValueId,
    this.fieldValue,
  });

  factory FormCustomField.fromJson(String str) => FormCustomField.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FormCustomField.fromMap(Map<String, dynamic> json) => FormCustomField(
        formId: json["form_id"],
        fillId: json["fill_id"],
        fieldId: json["field_id"],
        fieldName: json["field_name"],
        fieldType: json["field_type"],
        fieldIconData: json["field_icon"] != null ? IconData(int.parse(json["field_icon"]), fontFamily: 'MaterialIcons') : null,
        fieldIcon: json["field_icon"],
        fieldVisible: json["field_visible"],
        fieldOrder: json["field_order"],
        fieldValueId: json["field_value_id"],
        fieldValue: json["field_value"],
        enumValues: json["enum_values"] == null ? [] : List<String>.from(json["enum_values"]!.map((x) => x)),
        enumVisible: json["enum_visible"],
      );

  Map<String, dynamic> toMap() => {
        "form_id": formId,
        "fill_id": fillId,
        "field_id": fieldId,
        "field_name": fieldName,
        "field_type": fieldType,
        "field_icon": fieldIcon,
        "field_visible": fieldVisible,
        "field_order": fieldOrder,
        "field_value_id": fieldValueId,
        "field_value": fieldValue,
        "enum_values": enumValues == null ? [] : List<dynamic>.from(enumValues!.map((x) => x)),
        "enum_visible": enumVisible,
      };
}
