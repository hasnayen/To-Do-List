import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/pages/update_todo_page.dart';
import 'package:todo_list/provider/todo_provider.dart';

import '../auth_pref.dart';
import 'login_page.dart';
import 'new_todo_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  late TodoProvider todoProvider;
  int _selectedIndex = 0;

  String _display = 'Nothing to do!';
  @override
  void didChangeDependencies() {
    todoProvider = Provider.of<TodoProvider>(context, listen: false);
    todoProvider.getTodoByOwner();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo list',
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text(
                  'Logout',
                ),
                onTap: () {
                  setState(() {
                    setLoginStat(false).then((value) =>
                        Navigator.pushReplacementNamed(
                            context, LoginPage.routeName));
                  });
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, NewTodo.routeName);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            color: const Color(0xFFF6EFEF),
            child: Consumer<TodoProvider>(
                builder: (context, provider, _) => provider
                        .todoListByCondition.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _display,
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 30),
                            ),
                            Image.asset(
                              'assets/images/sleeping.gif',
                              height: 180,
                              width: 180,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.todoListByCondition.length,
                        itemBuilder: (context, index) {
                          final todo = provider.todoListByCondition[index];
                          final now = DateTime.now();
                          String date = todo.todoDate!;
                          // print('final- $date');
                          Color cardColor = const Color(
                              0xFFEFB9FD); //purple-8C52FF  pink-DF92F2 blue-5271FF

                          if (DateFormat('dd/MM/yyyy').format(DateTime.now()) ==
                              todo.todoDate!) {
                            date = 'Today';
                          }
                          if (DateFormat('dd/MM/yyyy').format(
                                  DateTime(now.year, now.month, now.day + 1)) ==
                              todo.todoDate!) {
                            date = 'Tomorrow';
                          }
                          if (DateFormat('dd/MM/yyyy').format(
                                  DateTime(now.year, now.month, now.day - 1)) ==
                              todo.todoDate!) {
                            date = 'Yesterday';
                          }
                          if (todo.todoPriority == 3) {
                            cardColor = const Color(0xFFB18CFB);
                          }
                          if (todo.todoPriority == 2) {
                            cardColor = const Color(0xFFBFFFE0);
                          }
                          return Dismissible(
                            key: ValueKey(todo.todoId),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: _showConfirmation,
                            onDismissed: (direction) {
                              provider.deleteTodo(todo.todoId);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              color: cardColor,
                              child: ListTile(
                                title: Text(
                                  todo.todoTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: todo.todoDate == null
                                    ? const Text('')
                                    : Text(date),
                                trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RatingBar.builder(
                                        itemCount: todo.todoPriority,
                                        maxRating: 3,
                                        ignoreGestures: true,
                                        itemBuilder: (context, _) {
                                          return const Icon(
                                            Icons.star,
                                            color: Colors.red,
                                          );
                                        },
                                        itemSize: 15,
                                        onRatingUpdate: (double value) {},
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      todo.todoTime == null
                                          ? const Text('')
                                          : Text(todo.todoTime!),
                                    ]),
                                leading: Checkbox(
                                  value: todo.todoIsCompleted,
                                  onChanged: (bool? val) {
                                    final val = todo.todoIsCompleted ? 0 : 1;
                                    // print('homepage: $val');
                                    provider.updateIsCompleted(
                                        index, todo.todoId!, val);
                                  },
                                ),
                                onTap: () => Navigator.pushNamed(
                                    context, UpdateTodoPage.routeName,
                                    arguments: [todo]),
                              ),
                            ),
                          );
                        },
                      ))),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        clipBehavior: Clip.antiAlias,
        child: Consumer<TodoProvider>(
          builder: (context, provider, _) => BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (value) {
              _selectedIndex = value;
              provider.loadContent(_selectedIndex);
              if (value == 0) {
                _display = 'Nothing to do!';
              }
              if (value == 1) {
                _display = 'Nothing to do today!';
              }
              if (value == 2) {
                _display = 'Nothing is overdue!';
              }
              if (value == 3) {
                _display = 'Nothing is completed!';
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.work,
                ),
                label: 'All',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.today),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                label: 'Overdue',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.done),
                label: 'Finished',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmation(DismissDirection direction) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete todo'),
              content: const Text('Are you sure?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('no')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('yes')),
              ],
            ));
  }
}
