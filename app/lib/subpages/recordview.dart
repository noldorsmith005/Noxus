// ------------------------------------------------------------------------------------
// Custom Recording Display Page ------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// Amp Meter import
import 'package:noxus/widgets/amp_meter.dart';
// Recorder import
import 'package:noxus/utilities/recorder.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';
// Main import
import 'package:noxus/main.dart';




class RecordView extends StatefulWidget {
  const RecordView({super.key, required this.setParentState});
  final Function setParentState;

  @override
  State<RecordView> createState() => _RecordViewState();
}
class _RecordViewState extends State<RecordView> {
  DatabaseHandler db = DatabaseHandler();
  Recorder recorder = Recorder();
  late StreamSubscription stream;
  List<double> amps = List.filled(40, 0.1, growable: true);
  bool recording = false;
  bool recorded = false;
  int max = 40;
  String? name;



  bool toneExists(List<Tone> tones, String curr, bool byName) {
    for (var tone in tones) {
      if (byName) {
        if (tone.name.toLowerCase() == curr.toLowerCase()) {
          return true;
        }
      }
      else {
        if (tone.file.toLowerCase() == curr.toLowerCase()) {
          return true;
        }
      }
    }
    return false;
  }

  String fileString(String input) {
    final name = input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .split(' ');

    return name.first + 
      name.skip(1).map((word) => word[0].toUpperCase() + word.substring(1)).join();
  }

  Future<void> saveRecordedFile(String new_file) async {
    final dir = await getApplicationSupportDirectory();
    final tempPath = '${dir.path}/audio/alarm/temp.wav';
    final targetPath = '${dir.path}/audio/alarm/$new_file.wav';
    File file = File(tempPath);
    if (await file.exists()) {
      await file.rename(targetPath);
    }
  }

  @override
  void initState() {
    super.initState();
    stream = recorder.ampStream().listen((amp) {
      final damp = ((1 / amp.current.abs()) * 10).clamp(0.0, 1.5);
      setState(() {
        amps.add(damp);
        if (amps.length > max) {
          amps.removeAt(0);
        }
      });
    });
  }

  void _cleanupTempFile() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final path = '${dir.path}/audio/alarm/temp.wav';
      File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error cleaning temp file: $e");
    }
  }

  @override
  void dispose() {
    stream.cancel();
    _cleanupTempFile();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        scrolledUnderElevation: 0.0,
        leading: SizedBox(),
        actions: <Widget>[
          (recorded && !recording) ? TextButton(
            onPressed: () async {
              if (name == null || name!.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("You must enter a name for your tone. "),
                  duration: Duration(seconds: 3),
                ));
              }
              else if (toneExists(appState.tones.custom, name as String, true)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Tone already exists. "),
                  duration: Duration(seconds: 3),
                ));
              }
              else {
                String new_file = fileString(name as String);
                await saveRecordedFile(new_file);
                Tone new_tone = Tone(name as String, "$new_file.wav");
                appState.tones.custom.add(new_tone);
                await appState.persistTones();
                if (context.mounted) {
                  Navigator.pop(context);
                  widget.setParentState(() {});
                }
              }
            },
            child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.blue)),
          ) : SizedBox()
        ],
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                cursorColor: Colors.white,
                cursorHeight: 30,
                maxLength: 20,
                maxLines: 1,
                autofocus: true,
                decoration: InputDecoration(
                  hint: Text("Enter tone name", style: TextStyle(fontSize: 17)),
                  border: InputBorder.none,
                  counterText: ""
                ),
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                onChanged: (value) {
                  name = value;
                },
              ),
            ),
            Spacer(),
            AmpMeter(amps: amps),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  if (recording == false) {
                    recorder.startRecording('audio/alarm', 'temp.wav');
                    setState(() {
                      recording = true;
                      recorded = true;
                    });
                  }
                  else {
                    recorder.stopRecording();
                    setState(() {
                      recording = false;
                    });
                  }
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: EdgeInsets.all(20),
                  shape: CircleBorder()
                ),
                child: (!recording) ? Icon(Icons.mic, size: 30, weight: 500, color: Colors.white) : Icon(Icons.square, size: 30, weight: 500, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}