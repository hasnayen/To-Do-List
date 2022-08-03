const String tableTodo = 'tblTodo';
const String tableTodoId = 'todoId';
const String tableTodoOwner = 'todoOwner';
const String tableTodoTitle = 'todoTitle';
const String tableTodoDescription = 'todoDescription';
const String tableTodoDate = 'todoDate';
const String tableTodoTime = 'todoTime';
const String tableTodoImage = 'todoImage';
const String tableTodoPriority = 'todoPriority';
const String tableTodoIsCompleted = 'todoIsCompleted';
const String tableTodoIsDue = 'todoIsDue';

class TodoModel {
  String todoTitle, todoOwner;
  String? todoDate, todoTime, todoDescription;
  int todoPriority;
  int? todoId;
  bool todoIsCompleted, todoIsDue;

  TodoModel({
    this.todoId,
    required this.todoTitle,
    required this.todoOwner,
    this.todoDescription,
    this.todoDate,
    this.todoTime,
    this.todoPriority = 2, //priority 1=low, 2=mid, 3=high
    this.todoIsCompleted = false,
    this.todoIsDue = false,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      tableTodoId: todoId,
      tableTodoTitle: todoTitle,
      tableTodoOwner: todoOwner,
      tableTodoDescription: todoDescription,
      tableTodoDate: todoDate,
      tableTodoTime: todoTime,
      tableTodoPriority: todoPriority,
      tableTodoIsCompleted: todoIsCompleted ? 1 : 0,
      tableTodoIsDue: todoIsDue ? 1 : 0
    };
    return map;
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) => TodoModel(
        todoId: map[tableTodoId],
        todoTitle: map[tableTodoTitle],
        todoOwner: map[tableTodoOwner],
        todoDescription: map[tableTodoDescription],
        todoDate: map[tableTodoDate],
        todoTime: map[tableTodoTime],
        todoPriority: map[tableTodoPriority],
        todoIsCompleted: map[tableTodoIsCompleted] == 1 ? true : false,
        todoIsDue: map[tableTodoIsDue] == 1 ? true : false,
      );

  @override
  String toString() {
    return 'TodoModel{todoTitle: $todoTitle, todoOwner: $todoOwner, todoDate: $todoDate, '
        'todoTime: $todoTime, todoDescription: $todoDescription, todoPriority: $todoPriority, '
        'todoIsCompleted: $todoIsCompleted, todoIsDue: $todoIsDue, todoId: $todoId}';
  }
}
