import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';




class Audio { 
  final player = AudioPlayer();

  Audio() {
    init();
  }

  Future<void> init() async {
    player.setLoopMode(LoopMode.one);
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> startWN(String file) async {
    try {
      final dir = await getApplicationSupportDirectory();
      String path = "${dir.path}/audio/whitenoise/$file";
      await player.setAudioSource(
        AudioSource.file(
          path,
          tag: MediaItem(
            id: 'white_noise',
            album: 'Sleep Cycle',
            title: 'White Noise',
          ),
        ),
      );
      await player.load();
      await player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> playTone(String file_path, String file) async {
    try {
      final dir = await getApplicationSupportDirectory();
      String path = "${dir.path}/$file_path/$file";
      await player.setAudioSource(
        AudioSource.file(
          path,
          tag: MediaItem(
            id: 'alarm',
            album: 'Sleep Cycle',
            title: 'Alarm',
          ),
        ),
      );
      await player.load();
      await player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> killPlayer() async {
    await player.stop();
    await player.dispose();
  }

}