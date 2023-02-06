import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:recorder/audio_player.dart';
import 'package:recorder/audio_recorder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> files = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return AudioPostComponent(
                  file: files[index],
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: AudioRecorder(
                onStop: (path) {
                  setState(() {
                    files.add(path);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
