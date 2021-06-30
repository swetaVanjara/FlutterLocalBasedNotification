class Reminder {
  int id;
  String uniqeidofreminder;
  String reminderinfo;
  String latitude;
  String longitude;

  Reminder({this.uniqeidofreminder, this.reminderinfo,this.latitude,this.longitude});
}

class ReminderDao  {
  final tableName = 'reminder';
  final columnId = 'id';
  final _columnUniqueId = 'uniqeidofreminder';
  final _columnReminderInfo = 'reminderinfo';
  final _columnLatitude = 'latitude';
  final _columnLongitude = 'longitude';


  @override
  String get createTableQuery =>
      "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY,"
          " $_columnUniqueId TEXT,"
          " $_columnReminderInfo TEXT,"
          " $_columnLatitude TEXT,"
          " $_columnLongitude TEXT)";

  @override
  Reminder fromMap(Map<String, dynamic> query) {
    Reminder note = Reminder();
    note.id = query[columnId];
    note.uniqeidofreminder = query[_columnUniqueId];
    note.reminderinfo = query[_columnReminderInfo];
    note.latitude = query[_columnLatitude];
    note.longitude = query[_columnLongitude];
    return note;
  }

  @override
  Map<String, dynamic> toMap(Reminder object) {
    return <String, dynamic>{
      _columnUniqueId: object.uniqeidofreminder,
      _columnReminderInfo: object.reminderinfo,
      _columnLatitude: object.latitude,
      _columnLongitude: object.longitude
    };
  }

  @override
  List<Reminder> fromList(List<Map<String,dynamic>> query) {
    List<Reminder> notes = List<Reminder>();
    for (Map map in query) {
      notes.add(fromMap(map));
    }
    return notes;
  }
}
