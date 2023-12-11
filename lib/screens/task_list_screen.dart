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
  Map<String, AnimationController> _controllers = {};

  @override
  void dispose() {
    // Dispose of all animation controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void addTask(String taskName) async {
    final newTask = Task(id: UniqueKey().toString(), name: taskName);
    await tasksBox.add(newTask);
    // Create a new controller for the new task
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controllers[newTask.id] = controller;
    controller.forward(); // Start the animation for adding
    setState(() {});
  }

  void deleteTask(Task task) async {
    // final controller = _controllers[task.id];
    // if (controller != null) {
    //   await controller.reverse();
    await task.delete();
    // _controllers.remove(task.id);
    // controller.dispose();
    setState(() {});
    //}
  }

  // Widget _buildAnimatedTask(AnimationController controller, Task task) {
  //   return SizeTransition(
  //     sizeFactor: CurvedAnimation(parent: controller, curve: Curves.easeOut),
  //     child: ListTile(
  //         title: Text(task.name, style: const TextStyle(color: Colors.white)),
  //         leading: CustomAnimatedCheckbox(
  //           value: task.completed,
  //           onChanged: (value) => toggleTaskCompleted(task),
  //         ),
  //         trailing: IconButton(
  //           icon: const Icon(Icons.delete, color: Colors.white),
  //           onPressed: () => deleteTask(task),
  //         )
  //     ),
  //   );
  // }

  void _showAddTaskDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add a new Tasks'),
        content: TextField(
          onSubmitted: (value) {
            addTask(value);
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

  @override
  void initState() {
    super.initState();
    tasksBox = widget.tasksBox;

    _controllers = {
      for (var k in tasksBox.keys) k.toString(): AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      )..forward(),
    };
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
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          List<Task> tasks = box.values.toList();
          if (tasks.isEmpty) {
            // If no tasks are present, display a placeholder
            return const Center(child: Text("No tasks yet", style: TextStyle(color: Colors.white)));
          }

          return buildCustomScrollView(tasks);
          // return ListView.builder(
          //   itemCount: tasks.length,
          //   itemBuilder: (context, index) {
          //     final task = tasks[index];
          //     final controller = _controllers[task.id];
          //     // If the controller does not exist for some reason, avoid building the widget
          //     if (controller == null) {
          //       return Container();
          //     }
          //     //return _buildAnimatedTask(controller, task);

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCustomScrollView(List<Task> tasks) {
    return CustomScrollView(slivers: <Widget>[
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
      SliverList(
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              if (index < tasks.length) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.name,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  leading: CustomAnimatedCheckbox(
                    value: task.completed,
                    onChanged: (value) => toggleTaskCompleted(task),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(task),
                  ),
                );
              } else {
                return null;
              }
            },
            childCount: tasks.length,
          )
      )
    ]);
  }
}




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
      duration: const Duration(milliseconds: 300),
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
