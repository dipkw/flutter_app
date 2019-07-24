import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../model/model.dart';
import '../util/utils.dart';
import '../util/dbhelper.dart';

//Menu Item
const menuDelete = "Delete";
final List<String> menuOptions = const<String> [
  menuDelete
];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();

  DocDetail(this.doc);

  @override
  State<StatefulWidget> createState() => DocDetailState();
}

class DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  final int daysAhead = 5475; // 15 years in the future

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController expirationCtrl = MaskedTextController(mask: '2000-00-00');

  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;

  void _initCtrls() {
    titleCtrl.text = widget.doc.title != null ? widget.doc.title : "";
    expirationCtrl.text = widget.doc.expiration != null ? widget.doc.expiration : "";

    fqYearCtrl = widget.doc.fqYear != null ? Val.IntToBool(widget.doc.fqYear) : false;
    fqHalfYearCtrl = widget.doc.fqHalfYear != null ? Val.IntToBool(widget.doc.fqHalfYear): false;
    fqQuarterCtrl = widget.doc.fqQuarter != null ? Val.IntToBool(widget.doc.fqQuarter): false;
    fqMonthCtrl = widget.doc.fqMonth != null ? Val.IntToBool(widget.doc.fqMonth): false;

    Future _chooseDate(BuildContext context, String initialDateString) async {
      var now = new DateTime.now();
      var initialDate = DateUtils.convertToDate(initialDateString) ?? now;

      initialDate = (initialDate.year >= now.year && initialDate.isAfter(now) ? initialDate : now);

      DatePicker.showDatePicker(context, showTitleActions: true, onConfirm: (date) {
        setState(() {
          DateTime dt = date;
          String r = DateUtils.ftDateAsStr(dt);
          expirationCtrl.text = r;
        });
      }, currentTime: initialDate);
    }
  }

  void _selectMenu(String value) async {
    switch(value) {
      case menuDelete:
        if(widget.doc.id == -1) {
          return;
        }
        await _deleteDoc(widget.doc.id);
    }
  }
  void _deleteDoc(int id) async {
      int r = await widget.dbh.deleteDoc(widget.doc.id);
      Navigator.pop(context, true);
  }

  void _saveDoc() {
    widget.doc.title = titleCtrl.text;
    widget.doc.expiration = expirationCtrl.text;

    widget.doc.fqYear = Val.BoolToInt(fqYearCtrl);
    widget.doc.fqHalfYear = Val.BoolToInt(fqHalfYearCtrl);
    widget.doc.fqQuarter = Val.BoolToInt(fqQuarterCtrl);
    widget.doc.fqMonth = Val.BoolToInt(fqMonthCtrl);

    if(widget.doc.id > -1) {
      debugPrint("_update->Doc Id: " + widget.doc.id.toString());
      widget.dbh.updateDoc(widget.doc);
      Navigator.pop(context);
    }
    else {
      Future<int> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insertDoc->Doc Id: " + widget.doc.id.toString());
        widget.doc.id = (result != null) ? result +1 : 1;
        widget.dbh.insertDoc(widget.doc);
        Navigator.pop(context);
      });
    }
  }
  void _submitForm() {
    final FormState form = _formKey.currentState;

    if(!form.validate()) {
      showMessage("Some data is invalid. Please correct.");
    }
    else {
      _saveDoc();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: color,
        content: new Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();

    @override
    Widget build(BuildContext context) {
      const String cStrDays = "Enter a number of days";
      
    }
  }
}
