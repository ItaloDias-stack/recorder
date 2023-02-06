import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPostComponent extends StatefulWidget {
  final String path;
  final bool showRemoveButton;
  final Function()? onRemove;

  const AudioPostComponent({
    Key? key,
    this.showRemoveButton = true,
    required this.path,
    this.onRemove,
  }) : super(key: key);

  @override
  AudioPostComponentState createState() => AudioPostComponentState();
}

class AudioPostComponentState extends State<AudioPostComponent> {
  AudioPlayer player = AudioPlayer();
  bool isLoading = true;
  bool isPlaying = false;
  bool isPaused = false;
  Duration position = const Duration();
  Duration audioDuration = const Duration();
  List<double> waveformdata = [];

  play() async {
    await player.play(DeviceFileSource(widget.path));
  }

  pause() async {
    await player.pause();
  }

  resume() async {
    await player.resume();
  }

  playPause() {
    if (isPlaying) {
      pause();
    } else if (isPaused) {
      resume();
    } else {
      play();
    }
  }

  Future getAudioDuration() async {
    audioDuration = await player.getDuration() ?? Duration.zero;
  }

  listenToAudioPosition() {
    player.onPositionChanged.listen((position) {
      setState(
        () => this.position = position,
      );
    });
  }

  listenToPlayerState() {
    player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        setState(() {
          isPlaying = true;
          isPaused = false;
        });
      } else if (event == PlayerState.paused) {
        setState(() {
          isPaused = true;
          isPlaying = false;
        });
      } else {
        setState(() {
          isPlaying = false;
          isPaused = false;
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await setAudioUrl();
      listenToAudioPosition();
      listenToPlayerState();
      await getAudioDuration();
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  Future<void> setAudioUrl() => player.setSourceUrl(widget.path);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 10, top: 15, bottom: 15, right: 15),
      margin: const EdgeInsets.only(bottom: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.withOpacity(.3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.showRemoveButton)
            GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey.withOpacity(.5),
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          if (widget.showRemoveButton)
            Container(
              height: 50,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              color: Colors.grey.withOpacity(.5),
            ),
          GestureDetector(
            onTap: () {
              playPause();
            },
            child: isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          Expanded(
            child: isLoading
                ? const LinearProgressIndicator(
                    color: Colors.grey,
                    backgroundColor: Colors.transparent,
                  )
                : Slider(
                    activeColor: Colors.purple,
                    inactiveColor: Colors.grey,
                    onChanged: (value) {
                      player.seek(
                        Duration(
                          seconds: (audioDuration.inSeconds * value).toInt(),
                        ),
                      );
                    },
                    value: position.inSeconds / audioDuration.inSeconds,
                  ),
          ),
        ],
      ),
    );
  }
}
