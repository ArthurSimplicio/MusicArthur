import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:musicarthur/repositories/music_repository.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeMusic extends StatefulWidget {
  const HomeMusic({super.key});

  @override
  State<HomeMusic> createState() => _HomeMusicState();
}

class _HomeMusicState extends State<HomeMusic> {
  final audioplayer = AudioPlayer();
  final music = MusicRepository.music;
  final CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  Future<void> setAudio(int index) async {
    audioplayer.stop(); // Pare a música atual
    audioplayer.setReleaseMode(ReleaseMode.loop);
    await audioplayer.play(AssetSource(music[index]['song']));
  }

  @override
  void dispose() {
    audioplayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setAudio(_current); // Inicialize a primeira música

    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioplayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioplayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Image.asset(
              music[_current]['image'],
              scale: 0.2,
            ),
            Positioned(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(1),
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0),
                    ])),
              ),
            ),
            Positioned(
              bottom: 50,
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                carouselController: _carouselController,
                items: music.map((mc) {
                  return Builder(builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Colors.white,
                            Color(0xff1f005c),
                            Color(0xff1f005c),
                            Color(0xff1f005c),
                            Color(0xff1f005c),                         
                            Color.fromARGB(255, 102, 8, 179),
                            Colors.white
                          ],
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              margin: const EdgeInsets.only(top: 30),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Image.asset(music[_current]['image']),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              mc['title'],
                              style: const TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                  ),
                            ),
                            Slider(
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) async {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  await audioplayer.seek(position);
                                }),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [],
                              ),
                            ),
                            CircleAvatar(
                              radius: 35,
                              child: IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: () async {
                                  if (isPlaying) {
                                    await audioplayer.pause();
                                  } else {
                                    await audioplayer.resume();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
                options: CarouselOptions(
                  height: 500.0,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.7,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                    setAudio(_current); // Mude a música ao trocar de página
                  },
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
