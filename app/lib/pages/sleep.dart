// ------------------------------------------------------------------------------------
// Sleep Page -------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:one_clock/one_clock.dart';
// Main import
import 'package:noxus/main.dart';
// Event Display import
import 'package:noxus/subpages/alarmview.dart';
// Cycle View import
import 'package:noxus/subpages/cycleview.dart';
// Database Import
import 'package:noxus/utilities/dbinterface.dart';




class Sleep extends StatefulWidget {
  @override
  State<Sleep> createState() => _SleepState();

}
class _SleepState extends State<Sleep> {
  DatabaseHandler db = DatabaseHandler();
  bool pending = false;
  var subscribed = 0;
  var events = 0;

  int w_hour = -1;
  int w_minute = -1;
  int s_hour = -1;
  int s_minute = -1;


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    DateTime dateTime = DateTime.now();

    void refresh() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }

    editWakeTime(SleepData sleep_data) {
      showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        showDragHandle: false,
        isDismissible: true,
        isScrollControlled: true,
        context: context, 
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Hour
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (w_hour + 24)),
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
                                  w_hour = (value%24);
                                },
                              ),
                            ),
                            Text(":", style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                            //Minute
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (w_minute + 60)),
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
                                  w_minute = (value%60);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              sleep_data.wake_time = "${(w_hour < 10)? "0$w_hour": "$w_hour"}:${(w_minute < 10)? "0$w_minute": "$w_minute"}"; 
                              pending = true;
                              appState.sleepData = sleep_data;
                              await db.editSleepData(sleep_data);
                              pending = false;
                              refresh();
                              if (context.mounted) {
                                Navigator.pop(context, "edited");
                              }
                            },
                            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                            child: const Text('Save', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          );
        }
      );
    }

    editBedTime(SleepData sleep_data) {
      showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        showDragHandle: false,
        isDismissible: true,
        isScrollControlled: true,
        context: context, 
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //Hour
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (s_hour + 24)),
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
                                  s_hour = (value%24);
                                },
                              ),
                            ),
                            Text(":", style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                            //Minute
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(initialItem: (s_minute + 60)),
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
                                  s_minute = (value%60);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              sleep_data.bed_time = "${(s_hour < 10)? "0$s_hour": "$s_hour"}:${(s_minute < 10)? "0$s_minute": "$s_minute"}"; 
                              pending = true;
                              appState.sleepData = sleep_data;
                              await db.editSleepData(sleep_data);
                              pending = false;
                              refresh();
                              if (context.mounted) {
                                Navigator.pop(context, "edited");
                              }
                            },
                            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                            child: const Text('Save', style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          );
        }
      );
    }
    

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: const Text("Sleep", style: TextStyle(fontWeight: FontWeight.bold)),
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
          List<Widget> children;
          Widget sleep_schedule;
          SleepData sleep_data = appState.sleepData;
          List<Alarm> alarms = sleep_data.alarms;
          w_hour = int.parse(sleep_data.wake_time!.split(":")[0]);
          w_minute = int.parse(sleep_data.wake_time!.split(":")[1]);
          s_hour = int.parse(sleep_data.bed_time!.split(":")[0]);
          s_minute = int.parse(sleep_data.bed_time!.split(":")[1]);
          alarms.isEmpty ? children = <Widget>[ Center(child: Text("No alarms yet")) ] :
          children = <Widget>[
            for (int i = 0; i < alarms.length; i++) 
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListTile(
                      title: Text("${alarms[i].time.split(":")[0]}:${alarms[i].time.split(":")[1]}", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                      trailing: Switch(
                        value: alarms[i].active,
                        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                        trackColor: (alarms[i].active)? WidgetStatePropertyAll(Colors.orange): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                        onChanged: (bool value) async {
                          alarms[i].active = value;
                          await db.editAlarm(i, alarms[i]);
                          refresh();
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AlarmView(index: i, alarm: alarms[i], RefreshEntries: refresh))
                        );
                      },
                    ),
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 10,
                    endIndent: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              )
          ];
          sleep_schedule = Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: AnalogClock(
                      decoration: BoxDecoration(
                          border: Border.all(width: 2.0, color: Colors.white),
                          color: Colors.transparent,
                          shape: BoxShape.circle),
                      width: 110,
                      height: 110,
                      isLive: true,
                      hourHandColor: Colors.white,
                      minuteHandColor: Colors.white,
                      numberColor: Colors.white,
                      tickColor: Colors.white,
                      showSecondHand: false,
                      showNumbers: true,
                      showAllNumbers: true,
                      showTicks: true,
                      showDigitalClock: false,
                      textScaleFactor: 1.4,
                      datetime: dateTime
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text("Bedtime:\n${sleep_data.bed_time!.split(":")[0]}:${sleep_data.bed_time!.split(":")[1]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          trailing: IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () {
                              editBedTime(sleep_data);
                            }, 
                          ),
                        ),
                        ListTile(
                          title: Text("Wake Time:\n${sleep_data.wake_time!.split(":")[0]}:${sleep_data.wake_time!.split(":")[1]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          trailing: IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () {
                              editWakeTime(sleep_data);
                            }, 
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.zero
                    ),
                    onPressed: () {
                      List<Alarm> active = [];
                      for (Alarm al in alarms) {
                        if (al.active) {
                          active.add(al);
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cycle(whitenoise: "", alarms: active))
                      );
                    }, 
                    child: Text("Sleep Tracker", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text("      Alarms", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.orange,
                    onPressed: () {
                      Alarm new_alarm = Alarm("00:00", "classic.mp3", 10, true, true);
                      int idx = alarms.length;
                      appState.sleepData.alarms.add(new_alarm);
                      db.postAlarm(new_alarm);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlarmView(index: idx, alarm: new_alarm, RefreshEntries: refresh))
                      );
                    },
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                indent: 2,
                endIndent: 2,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          );
          return Column(
            children: [
              SizedBox(width: 20.0, height: 20.0),
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: sleep_schedule,
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: children,
                    ),
                  )
                ],
              )
            ],
          );
        }
      ),
    );
  }
}