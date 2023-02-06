import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String) onStop;
  const AudioRecorder({
    required this.onStop,
    super.key,
  });

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  RecorderController recorderController = RecorderController();

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  Future<String> stop() async {
    return await recorderController.stop() ?? "";
  }

  Future start() async {
    await recorderController.record();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // if (recorderController.isRecording)
          //   StreamBuilder(
          //     stream: recorderController.,
          //     builder: (context, snapshot) {
          //       final duration = snapshot.hasData
          //           ? snapshot.data!.duration
          //           : Duration.zero;
          //       String twoDigits(int n) => n < 10 ? "0$n" : n.toString();
          //       final twoDigitsSeconds =
          //           twoDigits(duration.inSeconds.remainder(60));
          //       final twoDigitsMinutes =
          //           twoDigits(duration.inMinutes.remainder(60));
          //       return Text("$twoDigitsMinutes:$twoDigitsSeconds");
          //     },
          //   ),
          recorderController.isRecording
              ? Row(
                  children: [
                    const Text(
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
                        widget.onStop(path);
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.stop,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Text(
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
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.green,
                        ),
                      ),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
