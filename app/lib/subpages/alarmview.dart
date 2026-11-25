// ------------------------------------------------------------------------------------
// Alarm Display Page -----------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
// Main import
import 'package:noxus/main.dart';
// Tone Preview import
import 'package:noxus/widgets/tone_prev.dart';
// Number Selector import
import 'package:noxus/widgets/num_selector.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';


class AlarmView extends StatefulWidget {
  const AlarmView({super.key, required this.index, required this.alarm, required this.RefreshEntries});
  final int index;
  final Alarm alarm;
  final Function RefreshEntries;

  @override
  State<AlarmView> createState() => _AlarmViewState();
}
class _AlarmViewState extends State<AlarmView> {
  DatabaseHandler db = DatabaseHandler();

  bool pending = false;
  int hour = -1;
  int minute = -1;

  @override
  void initState() {
    super.initState();
    if (hour == -1) {
      int init_hour = int.parse(widget.alarm.time.split(":")[0]);
      hour = init_hour;
    }
    if (minute == -1) {
      int init_minute = int.parse(widget.alarm.time.split(":")[1]);
      minute = init_minute;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    bool toneExists(List<Tone> tones, String curr) {
      for (var tone in tones) {
        if (tone.file == curr) {
          return true;
        }
      }
      return false;
    }

    tonesPreview() {
      List<Tone> tones = [];
      tones.addAll(appState.tones.alarm);
      tones.addAll(appState.tones.custom);
      if (!toneExists(tones, widget.alarm.tone)) {
        widget.alarm.tone = "classic.mp3";
      }
      showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        showDragHandle: true,
        isDismissible: true,
        isScrollControlled: true,
        context: context, 
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setSubState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    TonePreview(
                      tones: tones, 
                      WNmode: false,
                      selected: widget.alarm.tone, 
                      setSelected: (sel) {
                        setState(() {
                          setSubState(() {
                            widget.alarm.tone = sel;
                          });
                        });
                      }
                    ),
                    SizedBox(height: 50),
                  ],
                )
              );
            },
          );
        }
      );
    }

    String getToneName(String file) {
      List<Tone> tones = [];
      tones.addAll(appState.tones.alarm);
      tones.addAll(appState.tones.custom);
      if (!toneExists(tones, widget.alarm.tone)) {
        widget.alarm.tone = "classic.mp3";
        file = "classic.mp3";
      }
      for (Tone tone in tones) {
        if (tone.file == file) {
          return tone.name;
        }
      }
      return "";
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: BackButtonIcon(),
          color: Colors.white,
          onPressed: () {
            if (pending == false) {
              widget.RefreshEntries();
              Navigator.of(context).pop();
            }
          }, 
        ),
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              pending = true;
              widget.alarm.time = "${(hour < 10)? "0$hour": "$hour"}:${(minute < 10)? "0$minute": "$minute"}"; 
              appState.sleepData.alarms[widget.index] = widget.alarm;
              db.editAlarm(widget.index, widget.alarm);
              widget.RefreshEntries();
              if (context.mounted) {
                Navigator.pop(context, "Save");
              }
              pending = false;
            },
            child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.blue)),
          ),
        ]
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                    height: 20,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Hour
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (hour + 24)),
                                useMagnifier: true,
                                magnification: 1.3,
                                itemExtent: 60, 
                                perspective: 0.01,
                                diameterRatio: 2,
                                physics: FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: ((index % 24) < 10)? Text('0${index % 24}', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.normal)): Text('${index % 24}', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.normal)),
                                    );
                                  },
                                  childCount: 100,
                                ),
                                onSelectedItemChanged: (value) {
                                  HapticFeedback.mediumImpact();
                                  hour = (value%24);
                                },
                              ),
                            ),
                            Text(":", style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                            //Minute
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (minute + 60)),
                                useMagnifier: true,
                                magnification: 1.3,
                                itemExtent: 60, 
                                perspective: 0.01,
                                diameterRatio: 2,
                                physics: FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: ((index % 60) < 10)? Text('0${index % 60}', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.normal)): Text('${index % 60}', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.normal)),
                                    );
                                  },
                                  childCount: 200,
                                ),
                                onSelectedItemChanged: (value) {
                                  HapticFeedback.mediumImpact();
                                  minute = (value%60);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Card(
                    color: const Color.fromARGB(100, 80, 80, 80),
                    child: ListTile(
                      title: Text("Touchless Mode "),
                      trailing: Switch(
                        value: !widget.alarm.manual,
                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                        trackColor: (!widget.alarm.manual)? WidgetStatePropertyAll(Colors.orange): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                        onChanged: (value) {
                          setState(() {
                            widget.alarm.manual = !widget.alarm.manual;
                          });
                        },
                      ),
                    ),
                  ),
                  (!widget.alarm.manual)? Card(
                    color: const Color.fromARGB(100, 80, 80, 80),
                    child: ListTile(
                      title: Text("Alarm Duration (seconds) "),
                      trailing: NumSelector(
                        min: 10,
                        max: 60,
                        initial: widget.alarm.duration,
                        onChanged: (value) {
                          setState(() {
                            widget.alarm.duration = value;
                          });
                        },
                      )
                    ),
                  ) : SizedBox(height: 0),
                  Card(
                    color: const Color.fromARGB(100, 80, 80, 80),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text("Alarm Tone "),
                          Spacer(),
                          Text(getToneName(widget.alarm.tone), style: TextStyle(color: Colors.white, fontSize: 17))
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        tonesPreview();
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(100, 80, 80, 80),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        pending = true;
                        appState.sleepData.alarms.removeAt(widget.index);
                        db.deleteAlarm(widget.index);
                        pending = false;
                        widget.RefreshEntries();
                        if (context.mounted) {
                          Navigator.pop(context, 'Delete');
                        }
                      }, 
                      child: Text("Delete Alarm ", style: TextStyle(color: Colors.red))
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}