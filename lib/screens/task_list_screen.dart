
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  final Box<Task> tasksBox;
  const TaskListScreen({Key? key, required this.tasksBox}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

// todo: fix AnimatedTask

const String baseAssetURL =
    'https://wallpapers.com/images/hd/calm-aesthetic-desktop-em3zhejov40rr4yj';
const String headerImage = '$baseAssetURL.jpeg';

class _TaskListScreenState extends State<TaskListScreen> with TickerProviderStateMixin {
  late Box<Task> tasksBox;
  late List<Task> _tasks;
  late List<AnimationController> _controllers;
  //List<AnimationController> _controllers = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    openBox();
    super.initState();
    _tasks = []; // Initialize your tasks list here
    _controllers = _tasks.map((task) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )).toList();
  }

  @override
  void dispose() {
    // Dispose of all animation controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    tasksBox.close();
    super.dispose();
  }

  void _addTask(String taskName) async {
    openBox();
    final newTask = Task(id: UniqueKey().toString(), name: taskName);
    await tasksBox.add(newTask);
    setState(() {
      _tasks.insert(0, newTask); // Insert at the top of the list
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _controllers.insert(0, controller);
      controller.forward();
      _listKey.currentState!.insertItem(0);
    });
  }

  void deleteTask(Task task, int index) async {
    final controller = _controllers[index];
    await controller.reverse();
    await tasksBox.delete(task.key); // Use the key to delete the task from the box
    setState(() {
      _tasks.removeAt(index);
      _controllers.removeAt(index);
    });
    controller.dispose();
  }

  void _removeTask(int index) {
    // Call this method when you want to remove a task
    var task = _tasks.removeAt(index);
    _controllers[index].reverse().then<void>((void value) {
      _controllers.removeAt(index).dispose();
    });
    _listKey.currentState!.removeItem(index, (context, animation) {
      return _buildRemovedItem(task, animation);
    });
  }

  Widget _buildRemovedItem(Task task, Animation<double> animation) {
    // This builds the widget for the task that is being removed
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(task.name),
        // other list tile properties
      ),
    );
  }

  Widget _buildAnimatedTask(Animation<double> animation, Task task) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(task.name, style: const TextStyle(color: Colors.white)),
        leading: CustomAnimatedCheckbox(
          value: task.completed,
          onChanged: (value) => toggleTaskCompleted(task),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            // Find the index of the task to delete
            int index = _tasks.indexOf(task);
            // Remove the task from the list with an animation
            _listKey.currentState!.removeItem(
              index,
                  (context, animation) => _buildAnimatedTask(animation, task),
              duration: const Duration(milliseconds: 300),
            );
            // Perform the actual deletion
            deleteTask(task, index);
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add a new Task'),
        content: TextField(
          onSubmitted: (value) {
            _addTask(value); // Pass the task name directly
            Navigator.pop(context);
          },
          decoration: const InputDecoration(hintText: "Enter task name"),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future openBox() async {
    tasksBox = await Hive.openBox<Task>('tasks');
    setState(() {});
  }

  void toggleTaskCompleted(Task task) {
    task.completed = !task.completed;
    task.save();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Buddy'),
      ),
      body: CustomScrollView(
        slivers: <Widget> [
          SliverAppBar(
            expandedHeight: 300.0,
            backgroundColor: Colors.teal[800],
            floating: false,
            pinned: true,
            onStretchTrigger: () async {
              if (kDebugMode) {
                print('Load new data');
              }
            },
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              title: const Text('Focus Buddy'),
              background: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: <Color>[Colors.cyan[900]!, Colors.transparent],
                  ),
                ),
                child: Image.network(
                  headerImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              // Provide a specific height if necessary
              height: 1,
              child: AnimatedList(
                  key: _listKey,
                  initialItemCount: _tasks.length,
                  itemBuilder: (context, index, animation) {
                    return _buildItem(_tasks[index], animation, index);
                  }
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(Task task, Animation<double> animation, int index) {
    // This builds the widget for each task in the list
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(task.name),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _removeTask(index);
          },
        ),
        // other list tile properties
      ),
    );
  }
}

// Widget buildCustomScrollView(List<Task> tasks) {
//   return CustomScrollView(slivers: <Widget>[
//     SliverAppBar(
//       expandedHeight: 300.0,
//       backgroundColor: Colors.teal[800],
//       floating: false,
//       pinned: true,
//       onStretchTrigger: () async {
//         if (kDebugMode) {
//           print('Load new data');
//         }
//       },
//       flexibleSpace: FlexibleSpaceBar(
//         stretchModes: const <StretchMode>[
//           StretchMode.zoomBackground,
//           StretchMode.blurBackground,
//           StretchMode.fadeTitle,
//         ],
//         title: const Text('Focus Buddy'),
//         background: DecoratedBox(
//           position: DecorationPosition.foreground,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.center,
//               colors: <Color>[Colors.cyan[900]!, Colors.transparent],
//             ),
//           ),
//           child: Image.network(
//             headerImage,
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     ),
//     SliverList(
//         delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//             if (index < tasks.length) {
//               final task = tasks[index];
//               return ListTile(
//                 title: Text(
//                   task.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//                 leading: CustomAnimatedCheckbox(
//                   value: task.completed,
//                   onChanged: (value) => toggleTaskCompleted(task),
//                 ),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () => deleteTask(task, index),
//                 ),
//               );
//             } else {
//               return null;
//             }
//           },
//           childCount: tasks.length,
//         )
//     )
//   ]);
// }




class ConstantScrollBehavior extends ScrollBehavior {
  const ConstantScrollBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.macOS;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

class CustomAnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomAnimatedCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomAnimatedCheckboxState createState() => _CustomAnimatedCheckboxState();
}

class _CustomAnimatedCheckboxState extends State<CustomAnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sizeAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.value) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CustomAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.value ? Colors.transparent : Colors.white,
          // Makes the entire container clickable
          border: Border.all(
            color: widget.value ? Colors.transparent : Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        width: 24.0,
        height: 24.0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Icon(
              Icons.check,
              color: widget.value ? Colors.blue : Colors.transparent,
              size: _sizeAnimation.value,
            );
          },
        ),
      ),
    );
  }
}
