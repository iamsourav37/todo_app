class Todo {
  int _id;
  String _title;
  String _description;
  String _date;
  String _time;
  int _priority;

  Todo(this._title, this._date, this._time, this._priority,
      [this._description]);

  // all getters

  int get id => this._id;
  String get title => this._title;
  String get description => this._description;
  String get date => this._date;
  String get time => this._time;
  int get priority => this._priority;

  // all setters

  set title(String title) {
    if (title.length <= 255) {
      this._title = title;
    }
  }

  set description(String description) {
    if (description.length <= 255) {
      this._description = description;
    }
  }

  set date(String date) {
    this._date = date;
  }

  set time(String time) {
    this._time = time;
  }

  set priority(int priority) {
    if (priority >= 1 && priority <= 2) this._priority = priority;
  }

  // ** Todo to map object
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    if (this._id != null) {
      map['id'] = this._id;
    }
    map['title'] = this._title;
    map['description'] = this._description;
    map['date'] = this._date;
    map['time'] = this._time;
    map['priority'] = this._priority;

    return map;
  }

  Todo.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._date = map['date'];
    this._time = map['time'];
    this._priority = map['priority'];
  }
}
