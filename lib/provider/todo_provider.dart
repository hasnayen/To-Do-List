import 'package:flutter/material.dart';
import 'package:todo_list/db/db_todo.dart';

import '../auth_pref.dart';
import '../model/todo_model.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoModel> todoList = [];
  List<TodoModel> todoListByCondition = [];

  String? todoOwner = '';

  getAllTodo() {
    DBTodo.getAllTodo().then((value) {
      todoList = value;
      getUser().then((value) {
        todoOwner = value!;
        // print(todoOwner);
      });
      getTodoByOwner();
      notifyListeners();
    });
  }

  getTodoByOwner() async {
    todoOwner = await getUser();
    // print('owner: $todoOwner');
    if (todoOwner != null) {
      DBTodo.getTodoByOwner(todoOwner!).then((value) {
        todoListByCondition = value;
        // print(todoListByCondition.length);
        notifyListeners();
      });
    }
  }

  Future<bool> addNewTodo(TodoModel todoModel) async {
    final rowId = await DBTodo.createTodo(todoModel);

    if (rowId > 0) {
      todoModel.todoId = rowId;
      todoListByCondition.add(todoModel);
      notifyListeners();
      return true;
    }
    return false;
  }

  loadContent(int index) {
    switch (index) {
      case 0:
        {
          getTodoByOwner();
          break;
        }
      case 1:
        {
          getTodoOfThisDay();
          break;
        }
      case 2:
        {
          getTodoByOverdue();
          break;
        }
      case 3:
        {
          getTodoByFinished();
          break;
        }
    }
  }

  void getTodoOfThisDay() {
    DBTodo.getTodoOfToday(todoOwner!).then((value) {
      todoListByCondition = value;
      notifyListeners();
    });
  }

  void getTodoByOverdue() {
    DBTodo.getTodoOfOverdue(todoOwner!).then((value) {
      todoListByCondition = value;
      // print(todoListByCondition);
      notifyListeners();
    });
  }

  void getTodoByFinished() {
    DBTodo.getFinishedTodo(todoOwner!).then((value) {
      todoListByCondition = value;
      // print(todoListByCondition);
      notifyListeners();
    });
  }

  updateIsCompleted(int index, int todoId, int value) {
    DBTodo.updateIsCompletedField(todoOwner!, todoId, value).then((_) {
      // print('provider: $todoOwner $index , $value');
      todoListByCondition[index].todoIsCompleted =
          !todoListByCondition[index].todoIsCompleted;
      // todoListByCondition.removeAt(index);
      notifyListeners();
    });
  }

  void deleteTodo(int? todoId) async {
    final rowId = await DBTodo.deleteTodo(todoId!);

    if (rowId > 0) {
      todoListByCondition.removeWhere((element) => element.todoId == todoId);
      notifyListeners();
    }
  }

  Future<void> updateTodo(TodoModel todo) {
    // print('provider: $todo');
    return DBTodo.updateTodo(todo).then((_) {
      getTodoByOwner();
      notifyListeners();
    });
  }
}
