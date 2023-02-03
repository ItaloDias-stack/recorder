import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:just_audio/just_audio.dart';
import 'package:recorder/audio_player.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

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
      home: const AudioRecorder(),
    );
  }
}

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({
    Key? key,
  }) : super(key: key);

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();

  List<String> files = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await initRecorder();
    });
    super.initState();
  }

  @override
  void dispose() {
    recorder.stopRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    await Permission.microphone.request();
    final status = await Permission.microphone.status;
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      await recorder.openRecorder();
      recorder.setSubscriptionDuration(
        const Duration(milliseconds: 500),
      );
    } else {
      throw "Permission not granted";
    }
  }

  Future<String> stop() async {
    return await recorder.stopRecorder() ?? "";
  }

  Future start() async {
    await recorder.startRecorder(toFile: const Uuid().v4());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                //final player = AudioPlayer();
                //final _pageManager = PageManager(files[index]);
                // return Container(
                //   height: 70,
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                //   width: MediaQuery.of(context).size.width,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(30),
                //     color: Colors.grey.withOpacity(.3),
                //   ),
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       GestureDetector(
                //         onTap: () {
                //           files.remove(files[index]);
                //           setState(() {});
                //         },
                //         child: Container(
                //           height: 35,
                //           width: 35,
                //           alignment: Alignment.center,
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(30),
                //             color: Colors.grey.withOpacity(.5),
                //           ),
                //           child: Icon(Icons.close),
                //         ),
                //       ),
                //       Container(
                //         height: 50,
                //         width: 1,
                //         color: Colors.grey.withOpacity(.5),
                //       ),

                //       ValueListenableBuilder<ButtonState>(
                //         valueListenable: _pageManager.buttonNotifier,
                //         builder: (_, value, __) {
                //           switch (value) {
                //             case ButtonState.loading:
                //               return Container(
                //                 margin: const EdgeInsets.all(8.0),
                //                 width: 32.0,
                //                 height: 32.0,
                //                 child: const CircularProgressIndicator(),
                //               );
                //             case ButtonState.paused:
                //               return GestureDetector(
                //                 onTap: _pageManager.play,
                //                 child: const Icon(
                //                   Icons.play_arrow,
                //                   size: 32.0,
                //                 ),
                //               );
                //             case ButtonState.playing:
                //               return GestureDetector(
                //                 onTap: _pageManager.pause,
                //                 child: const Icon(
                //                   Icons.pause,
                //                   size: 32.0,
                //                 ),
                //               );
                //           }
                //         },
                //       ),
                //       ValueListenableBuilder<ProgressBarState>(
                //         valueListenable: _pageManager.progressNotifier,
                //         builder: (_, value, __) {
                //           return SizedBox(
                //             width: MediaQuery.of(context).size.width * .6,
                //             child: ProgressBar(
                //               timeLabelLocation: TimeLabelLocation.none,
                //               progress: value.current,
                //               buffered: value.buffered,
                //               total: value.total,
                //               onSeek: _pageManager.seek,
                //             ),
                //           );
                //         },
                //       ),
                //     ],
                //   ),
                // );
                return AudioPostComponent(
                  file: files[index],
                );
              },
            ),
          ),
          Expanded(child: Container()),
          Container(
            height: 65,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(),
                if (recorder.isRecording)
                  StreamBuilder(
                    stream: recorder.onProgress,
                    builder: (context, snapshot) {
                      final duration = snapshot.hasData
                          ? snapshot.data!.duration
                          : Duration.zero;
                      String twoDigits(int n) => n < 10 ? "0$n" : n.toString();
                      final twoDigitsSeconds =
                          twoDigits(duration.inSeconds.remainder(60));
                      final twoDigitsMinutes =
                          twoDigits(duration.inMinutes.remainder(60));
                      return Text("$twoDigitsMinutes:$twoDigitsSeconds");
                    },
                  ),
                recorder.isRecording
                    ? Row(
                        children: [
                          Text(
                            "Parar",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 15.71),
                          GestureDetector(
                            onTap: () async {
                              final path = await stop();
                              files.add(path);
                              setState(() {});
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(.2),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.stop,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            "Empezar a grabar",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 15.71),
                          GestureDetector(
                            onTap: () async {
                              await start();
                              setState(() {});
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(.2),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.green,
                              ),
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class PageManager {
//   final progressNotifier = ValueNotifier<ProgressBarState>(
//     ProgressBarState(
//       current: Duration.zero,
//       buffered: Duration.zero,
//       total: Duration.zero,
//     ),
//   );
//   final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

//   late AudioPlayer _audioPlayer;
//   PageManager(String path) {
//     _init(path);
//   }

//   void _init(String path) async {
//     _audioPlayer = AudioPlayer();
//     await _audioPlayer.setFilePath(path);

//     _audioPlayer.playerStateStream.listen((playerState) {
//       final isPlaying = playerState.playing;
//       final processingState = playerState.processingState;
//       if (processingState == ProcessingState.loading ||
//           processingState == ProcessingState.buffering) {
//         buttonNotifier.value = ButtonState.loading;
//       } else if (!isPlaying) {
//         buttonNotifier.value = ButtonState.paused;
//       } else if (processingState != ProcessingState.completed) {
//         buttonNotifier.value = ButtonState.playing;
//       } else {
//         _audioPlayer.seek(Duration.zero);
//         _audioPlayer.pause();
//       }
//     });

//     _audioPlayer.positionStream.listen((position) {
//       final oldState = progressNotifier.value;
//       progressNotifier.value = ProgressBarState(
//         current: position,
//         buffered: oldState.buffered,
//         total: oldState.total,
//       );
//     });

//     _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
//       final oldState = progressNotifier.value;
//       progressNotifier.value = ProgressBarState(
//         current: oldState.current,
//         buffered: bufferedPosition,
//         total: oldState.total,
//       );
//     });

//     _audioPlayer.durationStream.listen((totalDuration) {
//       final oldState = progressNotifier.value;
//       progressNotifier.value = ProgressBarState(
//         current: oldState.current,
//         buffered: oldState.buffered,
//         total: totalDuration ?? Duration.zero,
//       );
//     });
//   }

//   void play() {
//     _audioPlayer.play();
//   }

//   void pause() {
//     _audioPlayer.pause();
//   }

//   void seek(Duration position) {
//     _audioPlayer.seek(position);
//   }

//   void dispose() {
//     _audioPlayer.dispose();
//   }
// }

// class ProgressBarState {
//   ProgressBarState({
//     required this.current,
//     required this.buffered,
//     required this.total,
//   });
//   final Duration current;
//   final Duration buffered;
//   final Duration total;
// }

// enum ButtonState { paused, playing, loading }
