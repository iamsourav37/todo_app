import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/database_helper.dart';
import '../models/Todo.dart';
import 'package:intl/intl.dart';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  final String title;

  TodoDetail(this.title, this.todo);
  @override
  _TodoDetailState createState() => _TodoDetailState(this.title, this.todo);
}

class _TodoDetailState extends State<TodoDetail> {
  Todo todo;
  String tittle;
  DatabaseHelper dbHelper = DatabaseHelper();
  GlobalKey<FormState> _key = GlobalKey();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<String> priorities = ['High', 'Low'];

  // constructor
  _TodoDetailState(this.tittle, this.todo);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _titleController.text = todo.title;
    _descriptionController.text = todo.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.tittle),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Form(
          key: _key,
          child: ListView(
            children: [
              getTitleTextField(),
              getDescriptionTextField(),
              getDropdown(),
              SizedBox(
                height: 50.0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 20.0,
                  ),
                  getSaveButton(),
                  SizedBox(
                    width: 18.0,
                  ),
                  getDeleteButton(context),
                  SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    moveToHomePage();
    todo.date = DateFormat.yMMMMd().format(DateTime.now());
    todo.time = DateFormat.jms().format(DateTime.now());
    todo.title = _titleController.text;
    todo.description = _descriptionController.text;
    if (todo.id == null) {
      // new todo , insert it
      var result = await dbHelper.insert(todo);
      if (result != 0) {
        // inserted successfully
        this.showAlertDialog(
            "Status", "New todo save successfully !", Colors.green[900]);
      } else {
        // problem to insert
        this.showAlertDialog(
            "Status", "problem to saving the todo !", Colors.red[900]);
      }
    } else {
      // existing todo, update it
      var result = await dbHelper.update(todo);
      if (result != 0) {
        this.showAlertDialog(
            "Status", "Update successfully !", Colors.green[900]);
      } else {
        this.showAlertDialog("Status", "Update failed !", Colors.red);
      }
    }
  }

  Future<void> _delete() async {
    moveToHomePage();
    var result = await dbHelper.delete(todo);
    if (result != 0) {
      showAlertDialog("Status", "Todo is Deleted", Colors.green);
    } else {
      showAlertDialog("Status", "Delete failed", Colors.red);
    }
  }

  moveToHomePage() {
    Navigator.pop(context, true);
  }

  showAlertDialog(String title, String msg, Color color) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(17.0),
          contentPadding: EdgeInsets.all(34.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: color,
          title: Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.amber[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25.0,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Expanded getDeleteButton(BuildContext context) {
    return Expanded(
      child: RaisedButton(
        onPressed: () {
          log("Delete button clicked");

          if (_titleController.text.isEmpty) {
            // invalid delete , show snackbar
            Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 3000),
                backgroundColor: Colors.black87,
                content: Text(
                  "Nothing to delete !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else if (todo.id == null) {
            // here also invalid delete, show snackbar
            // did not save the todo , just show the snackbar
            Scaffold.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 3000),
                backgroundColor: Colors.black87,
                content: Text(
                  "You did't save it !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.0,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          } else {
            // id is not null, then delete the todo from database
            _delete();
          }
        },
        color: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          "Delete",
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Expanded getSaveButton() {
    return Expanded(
      child: RaisedButton(
        onPressed: () {
          if (_key.currentState.validate()) {
            log("Save button clicked");
            this._save();
          }
        },
        color: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          "Save",
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Padding getDropdown() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.low_priority),
        title: DropdownButton(
          value: getPriorityAsString(todo.priority),
          onChanged: (value) {
            setState(() {
              updatePriorityAsInt(value);
            });
          },
          elevation: 4,
          items: priorities
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  updatePriorityAsInt(String priority) {
    switch (priority) {
      case 'High':
        todo.priority = 1;
        break;
      case 'Low':
        todo.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int intPriority) {
    String stringPriority;
    switch (intPriority) {
      case 1:
        stringPriority = this.priorities[0];
        break;
      case 2:
        stringPriority = this.priorities[1];
    }
    return stringPriority;
  }

  Padding getDescriptionTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.description),
        title: TextFormField(
          autofocus: false,
          textInputAction: TextInputAction.send,
          controller: _descriptionController,
          style: TextStyle(
            fontSize: 26.0,
          ),
          cursorWidth: 5.2,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Padding getTitleTextField() {
    String errorText = "Title should be atleast 4 characters";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          autofocus: false,
          // in TextFormField , dont use onChanged and controller property together
          textInputAction: TextInputAction.send,
          controller: _titleController,
          validator: (value) {
            if (value.isEmpty || value.length < 4) {
              return errorText;
            }
          },
          style: TextStyle(
            fontSize: 26.0,
          ),
          cursorWidth: 5.2,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
              errorMaxLines: errorText.length ~/ 2,
              errorStyle: TextStyle(
                fontSize: 19.0,
                color: Colors.redAccent,
              )),
        ),
      ),
    );
  }
}
