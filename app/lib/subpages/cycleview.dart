// ------------------------------------------------------------------------------------
// Sleep Cycle Page -------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// Bar Graph import
import 'package:noxus/widgets/bar_graph.dart';
// Number Selector import
import 'package:noxus/widgets/num_selector.dart';
// Hold Button import
import 'package:noxus/widgets/hold_button.dart';
// Audio import
import 'package:noxus/utilities/audio.dart';
// Recorder import
import 'package:noxus/utilities/recorder.dart';
// Main import
import 'package:noxus/main.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';



class Cycle extends StatefulWidget {
  const Cycle({super.key, required this.whitenoise, required this.alarms});
  final List<Alarm> alarms;
  final String whitenoise;

  @override
  State<Cycle> createState() => _CycleState();
}
class _CycleState extends State<Cycle> {
  DatabaseHandler db = DatabaseHandler();
  Recorder recorder = Recorder();
  late Audio audioHandler;
  String? peak_hour;
  bool peak = false;
  bool recording = false;

  int hour = -1;
  int minute = -1;

  int lucid = 0;
  int recalled = 0;
  List<dynamic> methods = [
    {
      "name": "MILD",
      "used": false
    },
    {
      "name": "WBTB",
      "used": false
    },
    {
      "name": "WILD",
      "used": false
    },
    {
      "name": "FILD",
      "used": false
    }, 
    {
      "name": "SSILD",
      "used": false
    },
    {
      "name": "RAUSIS",
      "used": false
    },
    {
      "name": "Reality Checks",
      "used": false
    },
    {
      "name": "Dream Signs",
      "used": false
    }
  ];

  List<BarPoint> calcPoints(dynamic appState) {
    List<double> vals = appState.sleepData.REM_points;
    List<BarPoint> points = [];
    vals.sort();

    for (var val in vals) {
      double counter = 0;
      for (var num in vals) {
        if (val == num) {
          counter += 1;
        }
      }
      BarPoint point = BarPoint(val, counter);

      bool contains = false;
      for (var curr in points) {
        if (curr.x == point.x) {
          contains = true;
        }
      }
      if (contains == false) {
        points.add(point);
      }
    }
    if (points.isEmpty) {
      points.add(BarPoint(0, 0));
    }

    double sum_y = 0;
    for (var point in points) {
      sum_y += point.y;
    }
    if (sum_y > 0) {
      for (var point in points) {
        point.y = ((point.y / sum_y) * 10);
      }
    }

    return points;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var appState = context.read<AppState>();
      if (appState.trackerState.audioHandler == null) {
        audioHandler = Audio();
        appState.trackerState.audioHandler = audioHandler;
      }
      else {
        audioHandler = appState.trackerState.audioHandler;
      }
      if (appState.sleepData.REM_points.length >= 10) {
        List<BarPoint> points = calcPoints(appState);
        double max_y = 0;
        double x = 0;
        for (var point in points) {
          if (point.y > max_y) {
            max_y = point.y;
            x = point.x;
          }
        }
        if ((x % 1) == 0) {
          peak_hour = valConvert(x.round());
        }
        else {
          peak_hour = ("${valConvert((x.round() - 1)).split(":")[0]}:30");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    Future<void> clearOldData() async {
      appState.lnData.recalled = 0;
      appState.lnData.lucid = 0;
      appState.lnData.methods.clear();
      appState.trackerState.tempRP.clear();
      final dir = await getApplicationSupportDirectory();
      for (var curr in appState.trackerState.tempVLs) {
        final path = '${dir.path}/audio/voicelogs/$curr';
        File file = File(path);
        if (await file.exists()) {
          await file.delete();
        } 
      }
      appState.trackerState.tempVLs.clear();
      appState.lnData.v_logs.clear();
      appState.persistLNData();
    }

    Future<void> cycleAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Sleep Summary: "),
            content: Column(
              children: [
                Text("How many dreams did you remember last night? "),
                SizedBox(height: 10),
                NumSelector(
                  min: 0,
                  max: 10,
                  initial: 0,
                  onChanged: (value) {
                    setState(() {
                      recalled = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text("How many Lucid Dreams did you have last night? "),
                SizedBox(height: 10),
                NumSelector(
                  min: 0,
                  max: 10,
                  initial: 0,
                  onChanged: (value) {
                    setState(() {
                      lucid = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                Text("What methods did you use last night? "),
                SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) {
                    return SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: methods.length,
                        itemBuilder: (context, idx) {
                          String method = methods[idx]["name"];
                          return ListTile(
                            title: Text(method),
                            trailing: Checkbox(
                              activeColor: Colors.green,
                              value: methods[idx]["used"], 
                              onChanged: (value) {
                                setState(() {
                                  methods[idx]["used"] = value;
                                });
                              }
                            ),
                          );
                        }
                      ),
                    );
                  }
                ),
                SizedBox(height: 20),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  for (var method in methods) {
                    method["used"] = false;
                  }
                  recalled = 0;
                  lucid = 0;
                  Navigator.pop(context, 'Cancel');
                },
              ),
              TextButton(
                child: const Text("Skip", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  audioHandler.pause();
                  audioHandler.killPlayer();
                  clearOldData();
                  appState.trackerState.audioHandler = null;
                  appState.trackerState.sleepActive = false;
                  if (context.mounted) {
                    Navigator.pop(context, 'Skip');
                    Navigator.pop(context);
                  }
                },
              ),
              TextButton(
                child: const Text("End", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  audioHandler.pause();
                  audioHandler.killPlayer();
                  for (var method in methods) {
                    if (method["used"] == true) {
                      appState.lnData.methods.add(method["name"]);
                    }
                  }
                  appState.lnData.lucid = lucid;
                  appState.lnData.recalled = recalled;
                  appState.trackerState.audioHandler = null;
                  appState.trackerState.sleepActive = false;
                  if (appState.sleepData.REM_points.length < 50) {
                    appState.sleepData.REM_points.addAll(appState.trackerState.tempRP);
                  }
                  appState.lnData.v_logs.addAll(appState.trackerState.tempVLs);
                  appState.trackerState.tempRP.clear();
                  appState.trackerState.tempVLs.clear();
                  appState.persistSleepData();
                  appState.persistLNData();
                  appState.calcStats();
                  Navigator.pop(context, 'End');
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

     DateTime nextAlarm(Alarm alarm) {
      final now = DateTime.now();
      int hour = int.parse(alarm.time.split(":")[0]);
      int minute = int.parse(alarm.time.split(":")[1]);

      final alarm_dt = DateTime(now.year, now.month, now.day, hour, minute);
      if (alarm_dt.isAfter(now)) {
        return alarm_dt;
      } 
      else {
        return alarm_dt.add(Duration(days: 1));
      }
    }

    List<Alarm> sortAlarms(List<Alarm> alarms) {
      List<Alarm> sorted = alarms.toList();

      sorted.sort((a, b) {
        final a_time = nextAlarm(a);
        final b_time = nextAlarm(b);
        return a_time.compareTo(b_time);
      });

      return sorted;
    }

    Future<void> triggerAlarm(Alarm alarm, Audio audioHandler) async {
      await Future.delayed(Duration(milliseconds: 500));
      audioHandler.playTone("audio/alarm", alarm.tone);

      if (alarm.manual == false) {
        await Future.delayed(Duration(seconds: alarm.duration));
      }
      else {
        await appState.manualAlarm();
      }
      audioHandler.pause();
      await Future.delayed(Duration(milliseconds: 500));
    }

    Future<void> startAlarms(List<Alarm> alarms) async {
      List<Alarm> sorted = sortAlarms(alarms);
      await Future.delayed(Duration(milliseconds: 500));
      audioHandler.startWN(appState.settings.whitenoise);
      for (var alarm in sorted) {
        if (!appState.trackerState.sleepActive) break;

        int set_hour = int.parse(alarm.time.split(":")[0]);
        int set_minute = int.parse(alarm.time.split(":")[1]);

        while (appState.trackerState.sleepActive) {
          DateTime current = DateTime.now();
          await Future.delayed(Duration(seconds: 1));
          if (current.hour == set_hour && current.minute == set_minute) {
            break;
          }
          else {
            continue;
          }
        }

        if (!appState.trackerState.sleepActive) break;
        
        audioHandler.pause();
        await triggerAlarm(alarm, audioHandler);
        audioHandler.startWN(appState.settings.whitenoise);
      }
    }

    double timePointConvert(int hour, int minute) {
      int whole = 0;
      if (hour < 12) {
        whole = (hour + 12);
      }
      else {
        whole = (hour - 12);
      }
      double dec = (((minute / 60) * 2).round() / 2);
      double val = (whole + dec);
      return val;
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
            if (recording == false) {
              Navigator.pop(context);
            }
          }, 
        ),
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
        actions: <Widget>[
          (appState.trackerState.sleepActive) ? TextButton(
            onPressed: () {
              cycleAlert();
            },
            child: const Text("End", style: TextStyle(fontSize: 18, color: Colors.red)),
          ) : SizedBox()
        ]
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                DateTime now = DateTime.now();
                bool isPeak = false;
                if (appState.sleepData.REM_points.length >= 10 && peak_hour != null) {
                  int hour = int.parse(peak_hour!.split(":")[0]);
                  int minute = int.parse(peak_hour!.split(":")[1]);
                  DateTime start = DateTime(now.year, now.month, now.day, hour, minute).subtract(Duration(minutes: 30));
                  DateTime end = DateTime(now.year, now.month, now.day, hour, minute).add(Duration(minutes: 30));
                  if (now.isAfter(start) && now.isBefore(end)) {
                    isPeak = true;
                  }
                }

                if (isPeak != peak) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        peak = isPeak;
                      });
                    }
                  });
                }

                if (isPeak) {
                  return Text(
                    DateFormat('HH:mm:ss').format(now),
                    style: TextStyle(
                      fontSize: 50, 
                      color: Colors.purple,
                      shadows: [
                        Shadow(
                          blurRadius: 50,
                          color: Colors.purpleAccent,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                  );
                }
                return Text(
                  DateFormat('HH:mm:ss').format(now),
                  style: TextStyle(fontSize: 50, color: Colors.white),
                );
              },
            ),
            (peak)? Text(" Peak Dreamtime ", style: TextStyle(fontSize: 30, color: Colors.purple)) : SizedBox(),
            SizedBox(height: 130),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: (appState.trackerState.sleepActive) ? HoldButton(
                onComplete: () {
                  DateTime curr_time = DateTime.now();
                  double time = timePointConvert(curr_time.hour, curr_time.minute);
                  appState.trackerState.tempRP.add(time);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Dream Logged. "),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
              ) : ElevatedButton(
                onPressed: () {
                  clearOldData();
                  setState(() {
                    appState.trackerState.sleepActive = true;
                  });
                  startAlarms(widget.alarms);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(170, 75, 175, 80),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: EdgeInsets.all(61),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: CircleBorder()
                ),
                child: Text("Start "),
              )
            ),
            Spacer(),
            (appState.trackerState.sleepActive)? Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  String file_name = "voicelog${appState.trackerState.tempVLs.length.toString()}.wav";
                  if (appState.trackerState.tempVLs.length < 20) {
                     if (recording == false) {
                      audioHandler.pause();
                      recorder.startRecording("audio/voicelogs", file_name);
                      setState(() {
                        recording = true;
                      });
                    }
                    else {
                      recorder.stopRecording();
                      audioHandler.play();
                      DateTime now = DateTime.now();
                      final formatter = DateFormat.Hm();
                      final timestamp = formatter.format(now);
                      Tone new_vl = Tone(timestamp, file_name);
                      appState.trackerState.tempVLs.add(new_vl);
                      setState(() {
                        recording = false;
                      });
                    }
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Max voice logs reached. "),
                      duration: Duration(seconds: 3),
                    ));
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
            ) : SizedBox(),
          ],
        ),
      ),
    );
  }
}