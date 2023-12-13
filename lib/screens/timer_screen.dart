import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String baseAssetURL =
    'https://publish.purewow.net/wp-content/uploads/sites/2/2020/03/calming-pictures-cat.jpg?fit=728%2C524';
const String headerImage = '${baseAssetURL}assets/header.jpeg';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

// todo: add notifications for timer is done
// todo: add seconds

class _TimerScreenState extends State<TimerScreen> with AutomaticKeepAliveClientMixin{
  late Timer? _timer;
  int _timeInSeconds = 0;
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final player = AudioPlayer();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState()
  {
    super.initState();
    var androidInitialize = const AndroidInitializationSettings('ic_stat_notify.png');
    var initializationsSettings = InitializationSettings(android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  void startTimer() {
    _timeInSeconds = (int.tryParse(_hoursController.text) ?? 0) * 3600 +
        (int.tryParse(_minutesController.text) ?? 0) * 60;

    if (_timeInSeconds > 0) {
      _timer = Timer.periodic(
        const Duration(seconds: 1),
            (Timer timer) {
          if (_timeInSeconds < 1) {
            timer.cancel();
            _onTimerEnd();
          } else {
            setState(() {
              _timeInSeconds--;
            });
          }
        },
      );
    }
  }

  Future<void> _onTimerEnd() async {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('Time\'s up!'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Your timer is done.'),
                ],
              ),
            ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                player.pause();
              },
            ),
          ],
        );
      },
    );

    // loops until pause is press
    await player.setReleaseMode(ReleaseMode.loop);
    // Play timer done sound
    await player.play(AssetSource('audio/synth_bell.mp3'));

    // THis is the Schedule the notification
    // Schedule the notification
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'Local Notification',
      //'channelDescription',
      importance: Importance.high,
      priority: Priority.high,
    );

    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        0,
        'Timer Done',
        'Your timer has finished!',
        generalNotificationDetails,
    );

  }

  void pauseTimer() {
    _timer!.cancel();
  }

  void resetTimer() {
    _timer!.cancel();
    setState(() {
      _timeInSeconds = 0;
    });
  }


  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                  Text(
                    '${(_timeInSeconds ~/ 3600).toString().padLeft(
                        2, '0')}:${((_timeInSeconds % 3600) ~/ 60)
                        .toString()
                        .padLeft(2, '0')}:${(_timeInSeconds % 60)
                        .toString()
                        .padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(
                            labelText: 'Hours',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _minutesController,
                          decoration: const InputDecoration(
                            labelText: 'Minutes',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startTimer,
                    child: const Text('Start Timer'),
                  ),
                  // ... Other buttons
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
