import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';



class Recorder {
  final recorder = AudioRecorder();

  Stream<Amplitude> ampStream() {
    return recorder.onAmplitudeChanged(Duration(milliseconds: 200));
  }

  Future<void> startRecording(String file_path, String name) async {
    if (await recorder.hasPermission()) {
      final dir = await getApplicationSupportDirectory();
      final path = '${dir.path}/$file_path/$name';

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav
        ),
        path: path
      );
    }
  }

  Future<void> stopRecording() async {
    await recorder.stop(); 
  }

}