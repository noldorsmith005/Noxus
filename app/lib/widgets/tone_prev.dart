import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Main import
import 'package:noxus/main.dart';
// Audio import
import 'package:noxus/utilities/audio.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';



class TonePreview extends StatefulWidget {
  TonePreview({super.key, required this.tones, required this.WNmode, required this.selected, required this.setSelected});
  final Function setSelected;
  final List<Tone> tones;
  final bool WNmode;
  final String selected;

  @override
  State<TonePreview> createState() => _TonePreviewState();
}

class _TonePreviewState extends State<TonePreview> {
  final Audio audioHandler = Audio();

  @override
  void dispose() {
    super.dispose();
    audioHandler.killPlayer();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: widget.tones.length,
        itemBuilder: (context, idx) {
          Tone tone = widget.tones[idx];
          if (widget.WNmode && tone.file == "none.mp3") {
            return SizedBox();
          }
          else {
            return Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.white, 
                  width: (tone.file == widget.selected)? 2 : 0,           
                ),
                borderRadius: BorderRadius.circular(8), 
              ),
              child: ListTile(
                title: Text(tone.name),
                trailing: IconButton(
                  onPressed: () {
                    if (appState.trackerState.audioHandler == null) {
                      audioHandler.pause();
                      if (widget.WNmode) {
                        audioHandler.startWN(tone.file);
                      }
                      else {
                        audioHandler.playTone("audio/alarm", tone.file);
                      }
                    }
                  }, 
                  icon: Icon(Icons.volume_up, color: Colors.blue)
                ),
                onTap: () {
                  widget.setSelected(tone.file);
                },
              ),
            );
          }
        }
      ),
    );
  }
}