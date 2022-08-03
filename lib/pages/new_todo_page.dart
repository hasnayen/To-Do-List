import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/auth_pref.dart';
import 'package:todo_list/model/todo_model.dart';
import 'package:todo_list/provider/todo_provider.dart';

import '../notification_manager.dart';

class NewTodo extends StatefulWidget {
  static const String routeName = '/new_todo';

  @override
  State<NewTodo> createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  final priorityList = ['Low', 'Normal', 'High'];
  String _dropDownVal = 'Normal';

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String _date = '';
  TimeOfDay? _timeOfDay;
  bool _hasDate = false;
  bool _hasTime = false;

  final form_key = GlobalKey<FormState>();

  String? userName;

  @override
  void initState() {
    getUser().then((value) {
      userName = value;
      // print('user: $userName');
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New todo'),
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
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'What to do?',
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
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Details',
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
                          _hasDate ? _date : 'Due date',
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
                          _hasTime ? _timeOfDay!.format(context) : 'Due Time',
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
        _hasDate = true;
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
        _hasTime = true;
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
        todoTitle: titleController.text,
        todoOwner: userName!,
        todoDescription: descriptionController.text,
        todoDate: _date,
        todoTime: _timeOfDay?.format(context),
        todoPriority: priority,
      );

      final status = await Provider.of<TodoProvider>(context, listen: false)
          .addNewTodo(todo);

      if (status) {
        Navigator.pop(context);
        if (priority == 3 && _timeOfDay != null) {
          var time = _timeOfDay!.format(context);
          var dateTime =
              DateFormat('dd/MM/yyyy hh:mm aaa').parse('$_date $time');

          var difference = dateTime.difference(DateTime.now()).inSeconds;
          // print('diff- $difference');

          NotificationManager()
              .setNotification(difference, titleController.text, time);
        }
      }
    }
  }
}
