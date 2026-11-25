// ------------------------------------------------------------------------------------
// Log Page -----------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// BarGraph import
import 'package:noxus/widgets/bar_graph.dart';
// Audio import
import 'package:noxus/utilities/audio.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';
// Main import
import '../main.dart';



class LogPage extends StatefulWidget {
  @override
  State<LogPage> createState() => _LogPageState();
}
class _LogPageState extends State<LogPage> {
  DatabaseHandler db = DatabaseHandler();
  Audio audioHandler = Audio();
  final mapScrollController = ScrollController();
  final KeyField = TextEditingController();
  final VaultKey = GlobalKey<FormState>();
  bool editing = false;

  int? playingIndex;

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
  void dispose() {
    super.dispose();
    audioHandler.killPlayer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var appState = context.read<AppState>();
      if (appState.sleepData.REM_points.length >= 10) {
        List<BarPoint> points = calcPoints(appState);
        double max_y = 0;
        double off_x = 0;
        for (var point in points) {
          if (point.y > max_y) {
            max_y = point.y;
            off_x = point.x;
          }
        }
        double offset = (((1500 / 24) * off_x) - 100);
        mapScrollController.animateTo(offset, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    void refresh() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }

    addDreamSign() {
      return showDialog(
        context: context.mounted ? context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Form(
                key: VaultKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ListTile(
                        title: TextFormField(
                          autofocus: true,
                          obscureText: false,
                          controller: KeyField,
                          keyboardType: TextInputType.text,
                          cursorColor: Colors.grey,
                          decoration: InputDecoration(
                            hintText: 'Enter a dream sign. ',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please enter a dream sign. ';
                            }
                            if (value.isEmpty) {
                              return 'Please enter a dream sign. ';
                            }
                            if (value.length > 20) {
                              return 'Please make your entry shorter';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  KeyField.clear();
                  Navigator.pop(context, 'Cancel');
                }
              ),
              TextButton(
                child: const Text("Add", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (VaultKey.currentState!.validate()) {
                    Navigator.pop(context, 'Add');
                    appState.sleepData.dream_signs.add(KeyField.text);
                    KeyField.clear();
                    appState.persistSleepData();
                    refresh();
                  }
                },
              ),
            ],
          );
        },
      );
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: const Text("Sleep Data", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (appState.settings.key_active)
            IconButton(
              icon: const Icon(Icons.lock_outline, size: 26),
              tooltip: "Lock App",
              onPressed: () {
                appState.lockApp();
              },
            ),
        ],
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple,
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Text("Dream Times ", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        (appState.sleepData.REM_points.length >= 10)
                            ? Expanded(
                                child: SingleChildScrollView(
                                  controller: mapScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                    child: SizedBox(
                                      width: 1500,
                                      child: BarGraph(
                                        points: calcPoints(appState),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_outline, size: 36, color: Colors.purpleAccent),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${appState.sleepData.REM_points.length} / 10 Dreams Logged",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                                      child: LinearProgressIndicator(
                                        value: (appState.sleepData.REM_points.length / 10).clamp(0.0, 1.0),
                                        backgroundColor: Colors.white12,
                                        color: Colors.purpleAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        "Log 10 dreams to unlock REM cycle predictions.",
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text("Dream Signs ", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 210,
                          child: (appState.sleepData.dream_signs.isNotEmpty)? ListView.builder(
                            itemCount: appState.sleepData.dream_signs.length,
                            itemBuilder: (context, index) {
                              String curr_sign = appState.sleepData.dream_signs[index] as String;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.deepPurpleAccent,
                                        width: 3.0,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black87,
                                        blurRadius: 10
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      title: Text(curr_sign),
                                      trailing: (editing)? IconButton(
                                        onPressed: () {
                                          editing = false;
                                          appState.sleepData.dream_signs.removeAt(index);
                                          appState.persistSleepData();
                                          refresh();
                                        }, 
                                        icon: Icon(Icons.close, color: Colors.red)) : SizedBox()
                                    ),
                                  ),
                                ),
                              );
                            },
                          ) : null,
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(30, 158, 158, 158),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  padding: EdgeInsets.all(20),
                                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    editing = !editing;
                                  });
                                },
                                child: (editing)? Text("Cancel"): Text("Edit"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  padding: EdgeInsets.all(20),
                                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                  ),
                                ),
                                onPressed: () {
                                  if (appState.sleepData.dream_signs.length < 5) {
                                    addDreamSign();
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Tracking more than five dream signs can reduce their effectiveness. "),
                                      duration: Duration(seconds: 3),
                                    ));
                                  }
                                },
                                child: Text("New"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                ),
                SizedBox(height: 20),
                Text("Sleep Summary: ", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                Divider(
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                  color: Theme.of(context).colorScheme.outline,
                ),
                Column(
                  children: [
                    ListTile(
                      title: Text("Dreams Recalled: ", style: TextStyle(fontSize: 20)),
                      trailing: Text("${appState.lnData.recalled}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      title: Text("Lucid Dreams: ", style: TextStyle(fontSize: 20)),
                      trailing: Text("${appState.lnData.lucid}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    (appState.lnData.methods.isNotEmpty) ? Column(
                      children: [
                        Text("Methods Used: ", style: TextStyle(fontSize: 20)),
                        ListView.builder(
                          itemCount: appState.lnData.methods.length,
                          shrinkWrap: true,
                          itemBuilder: (context, idx) {
                            String method = appState.lnData.methods[idx] as String;
                            return Card(
                              color: Theme.of(context).colorScheme.surfaceContainerLow,
                              child: ListTile(
                                title: Text(method),
                              ),
                            );
                          },
                        )
                      ],
                    ) : SizedBox(),
                    SizedBox(height: 10),
                    (appState.lnData.v_logs.isNotEmpty) ? Column(
                      children: [
                        Text("Voice Logs: ", style: TextStyle(fontSize: 20)),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: appState.lnData.v_logs.length,
                            itemBuilder: (context, idx) {
                              Tone curr = appState.lnData.v_logs[idx];
                              return Card(
                                color: Theme.of(context).colorScheme.surfaceContainerLow,
                                child: ListTile(
                                  leading: IconButton(
                                    onPressed: () {
                                      if (playingIndex != idx) {
                                        audioHandler.pause();
                                        audioHandler.playTone("audio/voicelogs", curr.file);
                                        setState(() {
                                          playingIndex = idx;
                                        });
                                      }
                                      else {
                                        audioHandler.pause();
                                        setState(() {
                                          playingIndex = null;
                                        });
                                      }
                                    }, 
                                    icon: (playingIndex != idx)? Icon(Icons.play_arrow, color: Colors.white) : Icon(Icons.pause, color: Colors.white),
                                  ),
                                  trailing: Text("Timestamp: ${curr.name}", style: TextStyle(fontSize: 15)),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ) : SizedBox(),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
          );
        }
      ),
    );
  }
}