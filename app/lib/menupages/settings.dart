// ------------------------------------------------------------------------------------
// Settings Page ----------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
// Main import
import 'package:noxus/main.dart';
// Pin Code import
import 'package:noxus/widgets/pin_code.dart';
// Record View import
import 'package:noxus/subpages/recordview.dart';
// Num Selector import
import 'package:noxus/widgets/num_selector.dart';
// Tone Preview import
import 'package:noxus/widgets/tone_prev.dart';
// Notifications import
import 'package:noxus/utilities/notifications.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';



class SettingsPage extends StatefulWidget {

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  DatabaseHandler db = DatabaseHandler();
  final formKey = GlobalKey<FormState>();
  final vaultKey = GlobalKey<FormState>();
  final keyField = TextEditingController();
  final customKey = GlobalKey<FormState>();
  final customField = TextEditingController();
  bool pending = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    displayCustoms() {
      showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 25, 25, 25),
        showDragHandle: true,
        isDismissible: true,
        isScrollControlled: true,
        context: context, 
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: appState.tones.custom.length,
                        itemBuilder: (context, idx) {
                          Tone asset = appState.tones.custom[idx];
                          return ListTile(
                            title: Text(asset.name, style: TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              onPressed: () async {
                                final dir = await getApplicationSupportDirectory();
                                final path = '${dir.path}/audio/alarm/${asset.file}';
                                File file = File(path);
                                if (await file.exists()) {
                                  await file.delete();
                                } 
                                setState(() {
                                  appState.tones.custom.removeAt(idx);
                                  appState.persistTones();
                                });
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              icon: Icon(Icons.remove_circle_outline, color: Colors.red)
                            ),
                          );
                        }
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RecordView(setParentState: setState))
                        );
                      }, 
                      child: Text("Record New Tone ", style: TextStyle(color: Colors.white))
                    )
                  ],
                );
              }
            )
          );
        }
      );
    }

    tonesPreview() {
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
                      tones: appState.tones.whitenoise, 
                      WNmode: true,
                      selected: appState.settings.whitenoise, 
                      setSelected: (sel) {
                        setState(() {
                          setSubState(() {
                            appState.settings.whitenoise = sel;
                            appState.persistSettings();
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
      for (Tone tone in appState.tones.whitenoise) {
        if (tone.file == file) {
          return tone.name;
        }
      }
      return "";
    }

    Future<void> deleteHMAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("This removes all your dream heatmap data. This action cannot be undone and the data will be unrecoverable. "),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, 'Cancel'),
              ),
              TextButton(
                child: const Text("Reset", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context, 'Reset');
                  appState.sleepData.REM_points = [];
                  appState.persistSleepData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Dream Heatmap Reset "),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> deletePRAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("This resets all your dream stats and completed achievements. This action cannot be undone and the data will be unrecoverable. "),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, 'Cancel'),
              ),
              TextButton(
                child: const Text("Reset", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context, 'Reset');
                  appState.stats.r_streak = 0;
                  appState.stats.r_best = 0;
                  appState.stats.l_count = 0;
                  appState.stats.r_count = 0;
                  appState.stats.app_streak = 0;
                  appState.userData.manuals = false;
                  for (var curr in appState.achievements) {
                    curr.completed = false;
                  }
                  appState.lnData.lucid = 0;
                  appState.lnData.recalled = 0;
                  appState.lnData.methods = [];
                  appState.sleepData.dream_signs = [];
                  appState.persistLNData();
                  appState.persistUserData();
                  appState.persistSleepData();
                  appState.persistAchievements();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Dream Progress Reset "),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> clearJournalAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("This will permanently delete all journal entries. This action cannot be undone. Make sure you have exported your journal first if you wish to save it."),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, 'Cancel'),
              ),
              TextButton(
                child: const Text("Clear All", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.pop(context, 'Clear');
                  await appState.purgeEntries();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Journal cleared "),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> exportJournal() async {
      if (appState.entries.isNotEmpty) {
        final pdf = pw.Document();
        for (var entry in appState.entries) {
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "${entry.title}",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "${entry.date}",
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "${entry.content}",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.normal
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final baseDir = await getApplicationDocumentsDirectory();
        final file = File('${baseDir.path}/DreamJournal.pdf');
        await file.writeAsBytes(await pdf.save());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Journal saved to PDF "),
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No journal entries to export. "),
            duration: Duration(seconds: 2),
          ));
        }
      }
    }


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: BackButtonIcon(),
          color: Colors.white,
          onPressed: () {
            if (pending == false) {
              Navigator.of(context).pop();
            }
          }, 
        ),
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Notification Settings: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("Reality Check Reminders "),
                trailing: Switch(
                  value: appState.settings.rc_active,
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  trackColor: (appState.settings.rc_active)? WidgetStatePropertyAll(Colors.green): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  onChanged: (value) {
                    setState(() {
                      appState.settings.rc_active = value;
                      appState.persistSettings();
                    });
                    if (value == true) {
                      NotificationService().showNotification(
                        title: "Noxus",
                        body: "You will now receive reality check notifications. ",
                      );
                      appState.scheduleNotifications(appState.settings.rc_active, appState.settings.rc_random, appState.settings.rc_freq, appState.sleepData.bed_time as String, appState.sleepData.wake_time as String);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 1),
            (appState.settings.rc_active)? Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("Reality Check Randomizer "),
                trailing: Switch(
                  value: appState.settings.rc_random,
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  trackColor: (appState.settings.rc_random)? WidgetStatePropertyAll(Colors.green): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  onChanged: (value) {
                    setState(() {
                      appState.settings.rc_random = value;
                      appState.persistSettings();
                    });
                  },
                ),
              ),
            ) : SizedBox(height: 0),
            SizedBox(height: 1),
            (appState.settings.rc_active)? Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("Reality Check Frequency"),
                trailing: NumSelector(
                  min: 3,
                  max: 15,
                  initial: appState.settings.rc_freq,
                  onChanged: (value) {
                    setState(() {
                      appState.settings.rc_freq = value;
                      appState.persistSettings();
                    });
                  },
                )
              ),
            ) : SizedBox(height: 0),
            SizedBox(height: 1),
            Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("Achievement Notifications"),
                trailing: Switch(
                  value: appState.settings.ach_active,
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  trackColor: (appState.settings.ach_active)? WidgetStatePropertyAll(Colors.green): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  onChanged: (value) {
                    setState(() {
                      appState.settings.ach_active = value;
                      appState.persistSettings();
                    });
                    if (value == true) {
                      NotificationService().showNotification(
                        title: "Noxus",
                        body: "You will now receive a notification when an achievement is completed. ",
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Sleep Settings: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("White Noise "),
                trailing: Switch(
                  value: appState.settings.wn_active,
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  trackColor: (appState.settings.wn_active)? WidgetStatePropertyAll(Colors.green): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  onChanged: (value) {
                    setState(() {
                      appState.settings.wn_active = value;
                    });
                    if (value == true) {
                      appState.settings.whitenoise = "classic.mp3";
                    }
                    else {
                      appState.settings.whitenoise = "none.mp3";
                    }
                    appState.persistSettings();
                  },
                ),
              ),
            ),
            (appState.settings.wn_active) ? Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Row(
                  children: [
                    Text("Set White Noise "),
                    Spacer(),
                    Text(getToneName(appState.settings.whitenoise), style: TextStyle(color: Colors.white, fontSize: 17))
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  tonesPreview();
                },
              ),
            ) : SizedBox(),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                    displayCustoms();
                  }, 
                  child: Text("Manage Custom Alarms ")
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                    deleteHMAlert();
                  }, 
                  child: Text("Reset Dream Heatmap ", style: TextStyle(color: Colors.red))
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                    deletePRAlert();
                  }, 
                  child: Text("Reset Progress ", style: TextStyle(color: Colors.red))
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Security Settings: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(100, 80, 80, 80),
              child: ListTile(
                title: Text("App Lock Active "),
                trailing: Switch(
                  value: appState.settings.key_active,
                  trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                  trackColor: (appState.settings.key_active)? WidgetStatePropertyAll(Colors.green): WidgetStatePropertyAll(const Color.fromARGB(255, 80, 80, 80)),
                  thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  onChanged: (value) async {
                    if (value == false) {
                      await authenticate(context, appState);
                    }
                    setState(() {
                      appState.settings.key_active = value;
                      appState.persistSettings();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 5),
            (appState.settings.key_active) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                  onPressed: () async {
                    await authenticate(context, appState);
                    appState.settings.passkey = "";
                    appState.persistSettings();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("App Pin Reset. Restart the app. "),
                        duration: Duration(seconds: 3),
                      ));
                    }
                  }, 
                  child: Text("Reset Journal Key ")
                ),
              ),
            ) : SizedBox(height: 0),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                  onPressed: () async {
                    if (appState.settings.key_active) {
                      await authenticate(context, appState);
                    }
                    exportJournal();
                  }, 
                  child: Text("Export Journal ")
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                width: double.infinity,
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
                  onPressed: () async {
                    if (appState.settings.key_active) {
                      await authenticate(context, appState);
                    }
                    clearJournalAlert();
                  }, 
                  child: Text("Clear Journal ", style: TextStyle(color: Colors.red))
                ),
              ),
            ),
            SizedBox(height: 50)
          ],
        ),
      ) 
    );
  }
}