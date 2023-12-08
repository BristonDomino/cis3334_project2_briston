import 'package:flutter/material.dart';

const String baseAssetURL =
    'https://publish.purewow.net/wp-content/uploads/sites/2/2020/03/calming-pictures-cat.jpg?fit=728%2C524';
const String headerImage = '${baseAssetURL}assets/header.jpeg';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState  createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Focus Buddy'),
                  background: Image.network(
                    headerImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
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
                      )
                  )
              )
            ]
        )
    );
  }
}
