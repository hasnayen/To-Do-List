import 'package:flutter/material.dart';
import 'package:todo_list/db/db_todo.dart';

import '../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> userList = [];

  Future<void> getAllUsers() async {
    userList = await DBTodo.getAllUsers();
  }

  Future<bool> addNewUser(UserModel userModel) async {
    var tag = true;

    for (var element in userList) {
      // print(element.userName);
      if (userModel.userName == element.userName) {
        tag = false;
        break;
      }
    }
    if (tag) {
      final rowId = await DBTodo.createUser(userModel);

      if (rowId > 0) {
        userModel.userID = rowId;
        userList.add(userModel);
        notifyListeners();
      }
    } else {
      // throw 'User exists';
    }
    return tag;
  }

  bool loginUser(UserModel userModel) {
    var tag = false;

    // print(userList.toString());
    for (var element in userList) {
      // print(element.userName);
      if (userModel.userName == element.userName &&
          userModel.userPassword == element.userPassword) {
        tag = true;
        break;
      }
    }
    return tag;
  }
}
