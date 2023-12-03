import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //scrollBehavior: const ConstantScrollBehavior(),
      title: 'Focus Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class ConstantScrollBehavior  extends ScrollBehavior{
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    TaskListScreen(),
    TimerScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   //title: const Text('Focus Buddy'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

const String baseAssetURL =
    'https://dartpad-workshops-io2021.web.app/getting_started_with_slivers/';
const String headerImage = '${baseAssetURL}assets/header.jpeg';

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Map<String, dynamic>> tasks = [
    {'name': 'Task 1', 'completed': false},
    {'name': 'Task 2', 'completed': false},
    {'name': 'Task 3', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              backgroundColor: Colors.teal[800],
              floating: false,
              pinned: true,
              onStretchTrigger: () async {
                print('Load new data');
              },
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode> [
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
                      colors: <Color>[Colors.teal[800]!, Colors.transparent],
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
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task['name']),
                    leading: CustomAnimatedCheckbox(
                      value: task['completed'],
                      onChanged: (newValue) {
                        setState(() {
                          task['completed'] = newValue;
                        });
                      },
                    ),
                  );
                },
                childCount: tasks.length,
              ),
            ),
          ],
        )
    );
  }
}

// @override
// Widget build(BuildContext context)
// {
//   return ListView.builder(
//
//       itemCount: tasks.length,
//       itemBuilder: (context, index) {
//         final task = tasks[index];
//         return ListTile(
//             title: Text(task['name']),
//             leading: CustomAnimatedCheckbox(
//                 value: task['completed'],
//                 onChanged: (newValue) {
//                   setState(() {
//                     task['completed'] = newValue;
//                   });
//                 }
//             )
//         );
//       }
//   );
// }

Widget _buildAnimatedTask(Animation<double> animation, Map<String, dynamic> task) {
  return SizeTransition(
    sizeFactor: animation,
    child: ListTile(
      title: Text(task['name']),
      // Other list tile properties...
    ),
  );
}



class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(
            // this will be replaced with a custom timer indicator later
            value: null, // for now, it's an indermaintae progress indicator
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Placeholder for start timer functionality
                },
                child: const Text('Start'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Placeholder for pause timer functionality
                },
                child: const Text('Pause'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Placeholder for reset timer functionality
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          color: widget.value ? Colors.transparent : Colors.white, // Makes the entire container clickable
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


