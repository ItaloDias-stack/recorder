import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';

class AudioPostComponent extends StatefulWidget {
  final String file;
  final bool showRemoveButton;
  final Function()? onRemove;
  const AudioPostComponent(
      {Key? key,
      this.showRemoveButton = true,
      required this.file,
      this.onRemove})
      : super(key: key);

  @override
  _AudioPostComponentState createState() => _AudioPostComponentState();
}
// AudioFileWaveforms(
//                             size: Size(250, 50),
//                             playerController: playerController,
//                             waveformData: waveformdata,
//                             enableSeekGesture: true,
//                             waveformType: WaveformType.long,
//                             playerWaveStyle: const PlayerWaveStyle(
//                               scaleFactor: 100,
//                               fixedWaveColor: Colors.red,
//                               liveWaveColor: Colors.blue,
//                               waveCap: StrokeCap.round,
//                             ),
//                           )

// Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   audioAction();
//                                   //await audioPlayer.seek(Duration(milliseconds: 1200));
//                                 },
//                                 child: isPlaying && (position.inSeconds == 0)
//                                     ? Center(
//                                         child: CircularProgressIndicator(
//                                           color: Colors.brown,
//                                         ),
//                                       )
//                                     : isPlaying
//                                         ? Icon(Icons.pause)
//                                         : Icon(Icons.play_arrow),
//                               ),
//                             ],
//                           )
class _AudioPostComponentState extends State<AudioPostComponent> {
  bool isLoading = false;
  PlayerController playerController = PlayerController();
  bool isPlaying = false;
  bool isPaused = false;
  Duration position = Duration();
  Duration audioDuration = Duration();
  List<double> waveformdata = [];
  play() async {
    if (mounted) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      await playerController.startPlayer(forceRefresh: true);
      Future.delayed(Duration(milliseconds: 1500)).then((value) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  pause() async {
    if (mounted) {
      //await audioPlayer.pause();
      await playerController.stopPlayer();
    }
  }

  resume() async {
    if (mounted) {
      await playerController.startPlayer();
    }
  }

  seekAudio(Duration seekDuration) async {
    if (mounted) {
      await playerController.seekTo(seekDuration.inSeconds);
    }
  }

  audioAction() {
    if (mounted) {
      if (isPlaying) {
        pause();
      } else if (isPaused) {
        resume();
      } else {
        play();
      }
    }
  }

  getAudioDuration() {
    if (mounted) {
      playerController.onCurrentDurationChanged.listen((event) {
        if (mounted) {
          setState(
            () => audioDuration = Duration(milliseconds: event),
          );
        }
      });
    }
  }

  getAudioPosition() {
    if (mounted) {
      playerController.onCurrentDurationChanged.listen((event) {
        if (mounted) {
          setState(
            () => position = Duration(milliseconds: event),
          );
        }
      });
    }
  }

  listenToPlayerState() {
    if (mounted) {
      playerController.onPlayerStateChanged.listen((event) {
        if (event == PlayerState.playing) {
          if (mounted) {
            setState(() {
              isPlaying = true;
              isPaused = false;
            });
          }
        } else if (event == PlayerState.paused) {
          if (mounted) {
            setState(() {
              isPaused = true;
              isPlaying = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isPlaying = false;
              isPaused = false;
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      waveformdata = await playerController.extractWaveformData(
        path: widget.file,
        noOfSamples: 100,
      );
      setState(() {});
      await playerController.preparePlayer(
        path: widget.file,
        shouldExtractWaveform: true,
        volume: 1.0,
      );
      listenToPlayerState();
      getAudioDuration();
      getAudioPosition();
    });

    super.initState();
  }

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
                //if (widget.showRemoveButton) widget.onRemove!();
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
                child: Icon(Icons.close, size: 20),
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
              audioAction();
              //await audioPlayer.seek(Duration(milliseconds: 1200));
            },
            child: isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
          ),
          Expanded(
            child: AudioFileWaveforms(
              size: Size(250, 51),
              playerController: playerController,
              waveformData: waveformdata,
              //enableSeekGesture: true,

              waveformType: WaveformType.fitWidth, //WaveformType.long,
              playerWaveStyle: const PlayerWaveStyle(
                scaleFactor: 100,
                fixedWaveColor: Colors.red,
                liveWaveColor: Colors.blue,
                waveCap: StrokeCap.round,
                seekLineColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
