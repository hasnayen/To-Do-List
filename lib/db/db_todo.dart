import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/todo_model.dart';
import '../model/user_model.dart';

class DBTodo {
  static const String createTableUser = '''create table $tableUser(
  $tableUserId integer primary key,
  $tableUserName text,
  $tableUserPassword text
  )''';

  static const String createTableTodo = '''create table $tableTodo(
  $tableTodoId integer primary key,
  $tableTodoTitle text,
  $tableTodoOwner text,
  $tableTodoDescription text,
  $tableTodoDate text,
  $tableTodoTime text,
  $tableTodoPriority int,
  $tableTodoIsCompleted int,
  $tableTodoIsDue int
  )''';

  static Future<Database> open() async {
    final rootPath = await getDatabasesPath();

    final dbPath = join(rootPath, 'todo.db');

    return openDatabase(dbPath, version: 1, onCreate: (db, version) {
      db.execute(createTableUser);
      db.execute(createTableTodo);
    });
  }

  static Future<int> createUser(UserModel userModel) async {
    final db = await open();

    return db.insert(tableUser, userModel.toMap());
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await open();

    final List<Map<String, dynamic>> mapList = await db.query(tableUser);

    return List.generate(
        mapList.length, (index) => UserModel.fromMap(mapList[index]));
  }

  //all todo after this line

  static Future<int> createTodo(TodoModel todoModel) async {
    final db = await open();

    return db.insert(tableTodo, todoModel.toMap());
  }

  static Future<List<TodoModel>> getAllTodo() async {
    final db = await open();

    final List<Map<String, dynamic>> mapList = await db.query(tableTodo);

    return List.generate(
        mapList.length, (index) => TodoModel.fromMap(mapList[index]));
  }

  static Future<List<TodoModel>> getTodoByOwner(String ownerName) async {
    final db = await open();

    final List<Map<String, dynamic>> todoListByOwner = await db
        .query(tableTodo, where: '$tableTodoOwner = ?', whereArgs: [ownerName]);
    return List.generate(todoListByOwner.length,
        (index) => TodoModel.fromMap(todoListByOwner[index]));
  }

  static Future<List<TodoModel>> getTodoOfToday(String ownerName) async {
    final db = await open();
    final List<Map<String, dynamic>> mapList = await db.query(tableTodo,
        where: '$tableTodoDate = ? and $tableTodoOwner = ?',
        whereArgs: [
          DateFormat('dd/MM/yyyy').format(DateTime.now()),
          ownerName
        ]);

    return List.generate(
        mapList.length, (index) => TodoModel.fromMap(mapList[index]));
  }

  static Future<List<TodoModel>> getTodoOfOverdue(String owner) async {
    final db = await open();
    final List<Map<String, dynamic>> mapList = await db.query(tableTodo,
        where: '$tableTodoOwner = ? and $tableTodoIsCompleted = ?',
        whereArgs: [owner, 0]);

    List<TodoModel> result = [];
    var data = List.generate(
        mapList.length, (index) => TodoModel.fromMap(mapList[index]));
    for (var element in data) {
      if (element.todoDate != null && element.todoDate!.isNotEmpty) {
        var date = DateFormat('dd/MM/yyyy').parse(element.todoDate!);
        var stringNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
        var dateNow = DateFormat('dd/MM/yyyy').parse(stringNow);
        if (date.compareTo(dateNow) < 0) {
          result.add(element);
        }
      }
    }

    return result;
  }

  static Future<List<TodoModel>> getFinishedTodo(String owner) async {
    final db = await open();
    final List<Map<String, dynamic>> mapList = await db.query(tableTodo,
        where: '$tableTodoIsCompleted = ? and $tableTodoOwner = ?',
        whereArgs: [1, owner]);

    return List.generate(
        mapList.length, (index) => TodoModel.fromMap(mapList[index]));
  }

  static Future<int> updateIsCompletedField(
      String owner, int todoId, int value) async {
    final db = await open();
    // print('db: $owner , $value');

    return db.update(tableTodo, {tableTodoIsCompleted: value},
        where: '$tableTodoOwner = ? and $tableTodoId = ?',
        whereArgs: [owner, todoId]);
  }

  static deleteTodo(int todoId) async {
    final db = await open();

    return db.delete(tableTodo, where: '$tableTodoId = ?', whereArgs: [todoId]);
  }

  static Future<int> updateTodo(TodoModel todoModel) async {
    final db = await open();

    return db.update(
      tableTodo,
      {
        tableTodoId: todoModel.todoId,
        tableTodoTitle: todoModel.todoTitle,
        tableTodoDescription: todoModel.todoDescription,
        tableTodoDate: todoModel.todoDate,
        tableTodoTime: todoModel.todoTime,
        tableTodoPriority: todoModel.todoPriority,
      },
      where: '$tableTodoId = ? and $tableTodoOwner = ?',
      whereArgs: [todoModel.todoId, todoModel.todoOwner],
    );
  }
}
