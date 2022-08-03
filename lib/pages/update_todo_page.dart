import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/model/todo_model.dart';

import '../auth_pref.dart';
import '../notification_manager.dart';
import '../provider/todo_provider.dart';

class UpdateTodoPage extends StatefulWidget {
  static const String routeName = '/update_todo';

  @override
  State<UpdateTodoPage> createState() => _UpdateTodoPageState();
}

class _UpdateTodoPageState extends State<UpdateTodoPage> {
  late TodoModel todoModel;

  late String _date;

  late String _time;

  late String _dropDownVal;

  late TextEditingController titleController;
  late TextEditingController descriptionController;

  final priorityList = ['Low', 'Normal', 'High'];

  TimeOfDay? _timeOfDay;

  final form_key = GlobalKey<FormState>();

  String? userName;

  @override
  void initState() {
    getUser().then((value) {
      userName = value;
      print('user: $userName');
    });
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    var argList = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    todoModel = argList[0];
    // print(todoModel);

    titleController.text = todoModel.todoTitle;
    descriptionController.text =
        todoModel.todoDescription == null ? '' : todoModel.todoDescription!;

    _date = todoModel.todoDate == null || todoModel.todoDate!.isEmpty
        ? 'Update due Date'
        : todoModel.todoDate!;

    _time = todoModel.todoTime == null || todoModel.todoTime!.isEmpty
        ? 'Update due Time'
        : todoModel.todoTime!;

    if (todoModel.todoPriority == 1) {
      _dropDownVal = 'Low';
    } else if (todoModel.todoPriority == 2) {
      _dropDownVal = 'Normal';
    } else {
      _dropDownVal = 'High';
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update todo'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 8, right: 8),
        child: Form(
          key: form_key,
          child: ListView(
            children: [
              TextFormField(
                // initialValue: todoModel.todoTitle,
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Update what to do',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field must not be empty!';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Update additional details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _date,
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 15),
                        ),
                        const Icon(Icons.calendar_month),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _time,
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 15),
                        ),
                        const Icon(Icons.watch_later),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Set Priority: ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DropdownButton(
                      alignment: AlignmentDirectional.centerStart,
                      value: _dropDownVal,
                      items: priorityList.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          _dropDownVal = val!;
                        });
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));

    if (selectedDate != null) {
      setState(() {
        _date = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _timeOfDay = selectedTime;
        _time = _timeOfDay!.format(context);
      });
    }
  }

  void _saveTodo() async {
    if (form_key.currentState!.validate()) {
      int priority;
      if (_dropDownVal == 'Low') {
        priority = 1;
      } else if (_dropDownVal == 'Normal') {
        priority = 2;
      } else {
        priority = 3;
      }
      final todo = TodoModel(
        todoId: todoModel.todoId,
        todoTitle: titleController.text,
        todoOwner: userName!,
        todoDescription: descriptionController.text,
        todoDate: _date,
        todoTime: _time,
        todoPriority: priority,
      );

      await Provider.of<TodoProvider>(context, listen: false)
          .updateTodo(todo)
          .then((_) {
        Navigator.pop(context);
        if (priority == 3 && _timeOfDay != null) {
          var dateTime =
              DateFormat('dd/MM/yyyy hh:mm aaa').parse('$_date $_time');

          var difference = dateTime.difference(DateTime.now()).inSeconds - 300;

          // print('diff- $difference');

          NotificationManager()
              .setNotification(difference, titleController.text, _time);
        }
      });
    }
  }
}
