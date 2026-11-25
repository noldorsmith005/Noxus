import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
// Page imports
import 'package:noxus/pages/home.dart';
import 'package:noxus/pages/journal.dart';
import 'package:noxus/pages/log.dart';
import 'package:noxus/pages/sleep.dart';
// Pincode import
import 'package:noxus/widgets/pin_code.dart';
// Notifications import
import 'package:noxus/utilities/notifications.dart';
// Database import
import './utilities/dbinterface.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotifications();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.nategartland.noxus.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );

  final dir = await getApplicationSupportDirectory();
  final target_wndir = Directory('${dir.path}/audio/whitenoise');
  final target_aldir = Directory('${dir.path}/audio/alarm');
  final target_vldir = Directory('${dir.path}/audio/voicelogs');
  const List<String> al_audio_files = [
    'assets/audio/alarm/beeping.mp3',
    'assets/audio/alarm/beeping2.mp3',
    'assets/audio/alarm/beeping3.mp3',
    'assets/audio/alarm/bellTower.mp3',
    'assets/audio/alarm/birds.mp3',
    'assets/audio/alarm/classic.mp3',
    'assets/audio/alarm/classic2.mp3',
    'assets/audio/alarm/marimba.mp3',
    'assets/audio/alarm/oldPhone.mp3',
    'assets/audio/alarm/owl.mp3',
    'assets/audio/alarm/piano.mp3',
    'assets/audio/alarm/synth.mp3',
    'assets/audio/alarm/windchimes.mp3',
  ];
  const List<String> wn_audio_files = [
    'assets/audio/whitenoise/none.mp3',
    'assets/audio/whitenoise/classic.mp3',
    'assets/audio/whitenoise/forestWind.mp3',
    'assets/audio/whitenoise/oceanWaves.mp3',
    'assets/audio/whitenoise/rain.mp3',
    'assets/audio/whitenoise/stream.mp3',
  ];
  final wn_exists = await target_wndir.exists();
  final al_exists = await target_aldir.exists();
  final vl_exists = await target_vldir.exists();
  if (vl_exists == false) {
    print("Creating voice log directory... ");
    await target_vldir.create(recursive: true);
  }
  if (wn_exists == false) {
    print("Copying whitenoise files from assets...");
    await target_wndir.create(recursive: true);
    for (final asset in wn_audio_files) {
      final fileName = asset.split('/').last;
      final target_file = File("${target_wndir.path}/$fileName");
      final byteData = await rootBundle.load(asset);
      await target_file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }
  if (al_exists == false) {
    print("Copying tone files from assets...");
    await target_aldir.create(recursive: true);
    for (final asset in al_audio_files) {
      final fileName = asset.split('/').last;
      final target_file = File("${target_aldir.path}/$fileName");
      final byteData = await rootBundle.load(asset);
      await target_file.writeAsBytes(byteData.buffer.asUint8List());
    }
  }

  runApp(const Noxus());

  SystemChrome.setPreferredOrientations( [
      DeviceOrientation.portraitUp
    ]
  );
}

class Noxus extends StatelessWidget {
  const Noxus({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: "Noxus",
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 15, 20, 55),
            outline: Colors.white70,
            primary: const Color.fromARGB(255, 10, 14, 35),
            secondary: const Color.fromARGB(255, 18, 24, 60),
            surface: const Color.fromARGB(255, 15, 20, 45),
            primaryContainer: const Color.fromARGB(230, 10, 14, 30),
            surfaceContainerLow: const Color.fromARGB(90, 60, 60, 80),
            onPrimary: Colors.white,
            onSurface: Colors.white,
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            color: const Color.fromARGB(100, 40, 40, 60),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: const Color.fromARGB(240, 20, 25, 45),
            titleTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            contentTextStyle: const TextStyle(fontSize: 16, color: Colors.white70),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.purple.withValues(alpha: 0.3), width: 1.5),
            ),
            shadowColor: Colors.purpleAccent,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color.fromARGB(240, 25, 25, 40),
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.purpleAccent, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            behavior: SnackBarBehavior.floating,
            elevation: 8,
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}

class TrackerState {
  dynamic audioHandler;
  bool sleepActive = false;
  List<double> tempRP = [];
  List<Tone> tempVLs = [];
}


// ------------------------------------------------------------------------------------
// App State --------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class AppState extends ChangeNotifier {
  DatabaseHandler db = DatabaseHandler();
  TrackerState trackerState = TrackerState();
  late Function manualAlarm;
  int page_index = 0;
  Widget page = WelcomePage();
  bool locked = true;
  late UserData userData;
  late Stats stats;
  late Settings settings;
  late List<Entry> entries;
  late List<Achievement> achievements;
  late SleepData sleepData;
  late LNData lnData;
  late Tones tones;

  void unlockApp() {
    locked = false;
    notifyListeners();
  }

  void lockApp() {
    locked = true;
    notifyListeners();
  }

  void scheduleNotifications(bool on, bool random, int freq, String bed, String wake) {
    NotificationService().clearCache();
    List<String> prompts = ["Are you dreaming? ", "Do a reality check. ", "Notice anything strange? ", "How did you get here? "];
    if (on) {
      print("scheduling...");
      final rand = Random();
      DateTime current = DateTime.now();
      int hour1 = int.parse(wake.split(":")[0]);
      int min1 = int.parse(wake.split(":")[1]);
      int hour2 = int.parse(bed.split(":")[0]);
      int window = 0;
      if (hour2 > hour1) {
        window = ((hour2 - hour1) - 1);
      }
      else {
        window = ((24 - (hour1 - hour2)) - 1);
      }
      int interval = (((window * 60) / (freq - 1))).round();
      int start = (hour1 * 60) + min1;
      List<int> used = [];
      for (int i = 0; i < freq; i++) {
        late dynamic new_time;
        if (random) {
          final offset = rand.nextInt((window * 60));
          if (!used.contains(offset)) {
            new_time = (start + offset);
          }
          else {
            new_time = null;
          }
        }
        else {
          new_time = (start + (i * interval));
        }
        if (new_time != null) {
          int new_hour = ((new_time ~/ 60) % 24);
          int new_minute = (new_time % 60);
          String prompt = prompts[rand.nextInt(prompts.length)];
          if (current.hour < new_hour) {
            // print("$i -- ${current.month}/${current.day}/${current.year}  $new_hour:$new_minute");
            NotificationService().scheduleNotification(
              title: "Noxus",
              body: prompt,
              year: current.year,
              month: current.month,
              day: current.day,
              hour: new_hour,
              minute: new_minute
            );
          }
          else {
            DateTime tomorrow = current.add(Duration(days: 1));
            // print("$i -- ${tomorrow.month}/${tomorrow.day}/${tomorrow.year}  $new_hour:$new_minute");
            NotificationService().scheduleNotification(
              title: "Noxus",
              body: prompt,
              year: tomorrow.year,
              month: tomorrow.month,
              day: tomorrow.day,
              hour: new_hour,
              minute: new_minute
            );
          }
        }
      }
    }
  }

  Future<void> persistSettings() async {
    db.writeSettings(settings);
  }

  Future<void> persistUserData() async {
    db.writeUserData(userData);
  }

  Future<void> persistStats() async {
    db.writeStats(stats);
  }

  Future<void> persistSleepData() async {
    db.editSleepData(sleepData);
  }

  Future<void> persistLNData() async {
    db.editLNData(lnData);
  }

  Future<void> persistTones() async {
    db.editTones(tones);
  }

  Future<void> persistAchievements() async {
    db.editAchievements(achievements);
  }

  Future<void> purgeEntries() async {
    for (int i=0; i<entries.length; i++) {
      db.deleteEntry(i);
    }
    entries.clear();
  }


  Future<void> calcStats() async {
    if (lnData.recalled > 0) {
      stats.r_streak += 1;
      if (stats.r_streak > stats.r_best) {
        stats.r_best = stats.r_streak;
      }
    }
    else {
      stats.r_streak = 0;
    }
    stats.l_count += lnData.lucid;
    stats.r_count += lnData.recalled;
    persistStats();
    calcRewards();
  }

  Future<void> calcRewards() async {
    bool update = false;
    // Other
    if (userData.manuals) {
      Achievement curr = achievements[0];
      if (curr.completed == false) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.app_streak >= 30) {
      Achievement curr = achievements[8];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    // Journal 
    if (entries.length >= 5) {
      Achievement curr = achievements[1];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (entries.length >= 50) {
      Achievement curr = achievements[9];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (entries.length >= 100) {
      Achievement curr = achievements[14];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (entries.length >= 300) {
      Achievement curr = achievements[19];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    // Recall 
    if (stats.r_count >= 1) {
      Achievement curr = achievements[2];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.recalled > 1) {
      Achievement curr = achievements[4];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.r_count >= 10) {
      Achievement curr = achievements[5];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.r_count >= 50) {
      Achievement curr = achievements[10];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.r_count >= 100) {
      Achievement curr = achievements[13];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.r_count >= 500) {
      Achievement curr = achievements[17];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    // Awareness
    if (settings.rc_active) {
      Achievement curr = achievements[3];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (sleepData.dream_signs.isNotEmpty) {
      Achievement curr = achievements[6];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("Reality Checks") && lnData.lucid > 0) {
      Achievement curr = achievements[12];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("Dream Signs") && lnData.lucid > 0) {
      Achievement curr = achievements[16];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    // Lucid
    if (stats.l_count >= 1) {
      Achievement curr = achievements[7];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.l_count >= 10) {
      Achievement curr = achievements[11];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
            NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.l_count >= 50) {
      Achievement curr = achievements[15];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (stats.l_count >= 100) {
      Achievement curr = achievements[18];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    // Methods
    if (lnData.methods.contains("MILD") && lnData.lucid > 0) {
      Achievement curr = achievements[20];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("WBTB") && lnData.lucid > 0) {
      Achievement curr = achievements[21];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("WILD") && lnData.lucid > 0) {
      Achievement curr = achievements[22];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("FILD") && lnData.lucid > 0) {
      Achievement curr = achievements[23];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("SSILD") && lnData.lucid > 0) {
      Achievement curr = achievements[24];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }
    if (lnData.methods.contains("RAUSIS") && lnData.lucid > 0) {
      Achievement curr = achievements[25];
      if (!curr.completed) {
        curr.completed = true;
        update = true;
        if (settings.ach_active) {
          NotificationService().showNotification(
            title: "Noxus",
            body: "Achievement: ${curr.title} completed! ",
          );
        }
      }
    }

    if (update) {
      persistAchievements();
    }
  }

  Future<bool> loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    userData = await db.readUserData();
    stats = await db.readStats();
    settings = await db.readSettings();
    entries = await db.getEntries();
    achievements = await db.getAchievements();
    sleepData = await db.readSleepData();
    lnData = await db.readLNData();
    tones = await db.readTones();

    String prev = userData.last_active as String;
    DateTime curr_date = DateTime.now();
    if (prev == "") {
      stats.app_streak += 1;
    }
    else {
      DateTime prev_date = DateFormat('MM/dd/yyyy').parse(prev);
      if (curr_date.difference(prev_date).abs() > Duration(days: 2)) {
        stats.app_streak = 0;
        scheduleNotifications(settings.rc_active, settings.rc_random, settings.rc_freq, sleepData.bed_time as String, sleepData.wake_time as String);
      }
      else if (DateTime(prev_date.year, prev_date.month, prev_date.day).isBefore(DateTime(curr_date.year, curr_date.month, curr_date.day))) {
        stats.app_streak += 1;
        scheduleNotifications(settings.rc_active, settings.rc_random, settings.rc_freq, sleepData.bed_time as String, sleepData.wake_time as String);
      }
    }
    String date = DateFormat('MM/dd/yyyy').format(curr_date);
    userData.last_active = date;
    persistUserData();
    persistStats();
    
    calcRewards();

    return true;
  }

}

// ------------------------------------------------------------------------------------
// Home Page --------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  Future<bool>? _loadDataFuture;

  Future<void> manualAlarm() async {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "ALARM",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => Scaffold(
        backgroundColor: const Color.fromARGB(100, 158, 158, 158),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 5,
              padding: EdgeInsets.all(40),
              shape: CircleBorder()
            ),
            child: Icon(Icons.close, size: 30, weight: 500),
          ),
        ),
      ),
    );
  }


  @override 
  void initState() {
    super.initState();
    _loadDataFuture = context.read<AppState>().loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var appState = context.read<AppState>();
      appState.manualAlarm = () => manualAlarm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool> ( 
      future: _loadDataFuture,
      builder: (context, data) {
        Widget main;
        if (data.hasData) {
          main = KeyGuard();
        }
        else if (data.hasError) {
          main = Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('${data.error}'),
              ),
            ],
          );
        }
        else {
          main = Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Starting...", style: TextStyle(fontSize: 20)),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: const Color.fromARGB(255, 255, 255, 255),),
                  ),
                ],
              ),
            ),
          );
        }
        return main;
      }
    );

  }
}


class KeyGuard extends StatefulWidget {
  const KeyGuard();

  @override
  State<KeyGuard> createState() => _KeyGuardState();
}

class _KeyGuardState extends State<KeyGuard> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Builder(
      builder: (context) {
        if (appState.settings.passkey == "") {
          return setupKey(appState);
        }
        if (appState.settings.key_active && appState.locked) {
          return pinCode(appState);
        }
        else {
          return Main();
        }
      }
    );
  }
}

class Main extends StatefulWidget {
  const Main();

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final List<Widget> _pages = [
    WelcomePage(),
    Journal(),
    LogPage(),
    Sleep(),
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    void navbarPressed(int index) {
      setState(() {
        appState.page_index = index;
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: appState.page_index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime_outlined),
            label: 'Sleep',
          ),
        ],
        currentIndex: appState.page_index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: navbarPressed,
      ),
    ); 
  }
}

