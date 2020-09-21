import 'package:flutter/material.dart';
import '../models/database_helper.dart';
import '../models/Todo.dart';
import 'dart:async';
import 'dart:developer';
import 'todo_detail.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Todo> todoList;

  @override
  void initState() {
    super.initState();
    log("init state method invoked");
    this.updateListView();
  }

  Future<void> updateListView() async {
    log("UpdateListView method invoked");
    this.todoList = await dbHelper.getAllRowsAsTodoList();
    log("in updateListView Todo list : $todoList");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      return Scaffold(
        appBar: this._appBar(),
        body: this.showIsLoading(),
        floatingActionButton: this._addButton(),
      );
    } else {
      return Scaffold(
        appBar: this._appBar(),
        floatingActionButton: this._addButton(),
        body: Container(
          padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
          child: ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: EdgeInsets.only(bottom: 16.0),
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17.0),
                ),
                child: ListTile(
                  onTap: () {
                    this._navigateToDetailScreen("Edit Todo", todoList[index]);
                  },
                  contentPadding: EdgeInsets.fromLTRB(12, 10, 0, 5),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    child: this._getPriorityIcon(todoList[index].priority),
                    backgroundColor:
                        this._getIconBackColor(todoList[index].priority),
                  ),
                  title: Text(
                    todoList[index].title,
                    style: TextStyle(
                      fontSize: 24.0,
                      backgroundColor: Colors.teal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  subtitle: todoList[index].description.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoList[index].date,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.amber,
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              todoList[index].time,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              todoList[index].description,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 22.0,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoList[index].date,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              todoList[index].time,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      this._deleteFromHomePage(todoList[index]);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _appBar() {
    return AppBar(
      title: Text(
        "My Todo App",
        style: TextStyle(
          fontSize: 30.0,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget showIsLoading() {
    return Center(
      child: Text("Loading..."),
    );
  }

  FloatingActionButton _addButton() {
    return FloatingActionButton(
      backgroundColor: Colors.orangeAccent,
      elevation: 7.7,
      focusElevation: 5.5,
      child: Icon(
        Icons.add,
        color: Colors.black,
      ),
      onPressed: () {
        _navigateToDetailScreen("Add Todo", Todo("", "", "", 2, ""));
      },
    );
  }

  Widget _getPriorityIcon(int priority) {
    IconData icon = priority == 1 ? Icons.priority_high : Icons.low_priority;
    return Icon(
      icon,
    );
  }

  Color _getIconBackColor(int priority) {
    return priority == 1 ? Colors.yellow : Colors.grey[300];
  }

  _navigateToDetailScreen(String title, Todo todo) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetail(title, todo),
      ),
    );
    if (result == true) {
      log("Return to the home page with result $result");
      // update the todoList
      this.updateListView();
    }
  }

  Future _deleteFromHomePage(Todo todo) async {
    var result = await dbHelper.delete(todo);
    log("_deleteFromHomePage method , result is $result");
    this.updateListView();
  }
}
