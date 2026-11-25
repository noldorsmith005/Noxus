import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ------------------------------------------------------------------------------------
// User Data Class---------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class UserData {
  bool home;
  bool journal;
  bool log; 
  bool sleep;
  bool tracker;
  bool manuals;
  String? last_active;

  UserData(this.home, this.journal, this.log, this.sleep, this.tracker, this.manuals, this.last_active);

  Map<String, Object?> toJson() => {
    "home": home,
    "journal": journal,
    "log": log,
    "sleep": sleep,
    "tracker": tracker,
    "manuals": manuals,
    "last_active": last_active
  };

  factory UserData.fromJson(Map<String, Object?> json) {
    return UserData(
      json["home"] as bool,
      json["journal"] as bool,
      json["log"] as bool,
      json["sleep"] as bool,
      json["tracker"] as bool,
      json["manuals"] as bool,
      json["last_active"] as String?
    );
  }
}

// ------------------------------------------------------------------------------------
// Stats Class-------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Stats {
  int r_streak;
  int r_best;
  int l_count;
  int r_count;
  int app_streak;

  Stats(this.r_streak, this.r_best, this.l_count, this.r_count, this.app_streak);

  Map<String, Object?> toJson() => {
    "r_streak": r_streak,
    "r_best": r_best,
    "l_count": l_count,
    "r_count": r_count,
    "app_streak": app_streak
  };

  factory Stats.fromJson(Map<String, Object?> json) {
    return Stats(
      json["r_streak"] as int,
      json["r_best"] as int,
      json["l_count"] as int,
      json["r_count"] as int,
      json["app_streak"] as int
    );
  }
}

// ------------------------------------------------------------------------------------
// Settings Class----------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Settings {
  bool rc_active;
  bool ach_active;
  bool rc_random;
  int rc_freq;
  bool key_active;
  bool wn_active;
  String whitenoise;
  String passkey;

  Settings(this.rc_active, this.ach_active, this.rc_random, this.rc_freq, this.key_active, this.wn_active, this.whitenoise, this.passkey);

  Map<String, Object?> toJson() => {
    "rc_active": rc_active,
    "ach_active": ach_active,
    "rc_random": rc_random,
    "rc_freq": rc_freq,
    "key_active": key_active,
    "wn_active": wn_active,
    "whitenoise": whitenoise,
    "passkey": passkey,
  };

  factory Settings.fromJson(Map<String, Object?> json) => Settings(
    json["rc_active"] as bool,
    json["ach_active"] as bool,
    json["rc_random"] as bool,
    json["rc_freq"] as int,
    json["key_active"] as bool,
    json["wn_active"] as bool,
    json["whitenoise"] as String,
    json["passkey"] as String,
  );
}

// ------------------------------------------------------------------------------------
// Journal Entry Class-----------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Entry  {
  final String? date;
  final String? title;
  bool lucid;
  final String? content;

  Entry(this.date, this.title, this.lucid, this.content);

  Map<String, Object?> toJson() => {
    "date": date,
    "title": title,
    "lucid": lucid,
    "content": content
  };

  factory Entry.fromJson(Map<String, Object?> json) => Entry(
    json["date"] as String?,
    json["title"] as String?,
    json["lucid"] as bool,
    json["content"] as String?,
  );
}

// ------------------------------------------------------------------------------------
// Sleep Data Class--------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class SleepData {
  String? bed_time;
  String? wake_time;
  List<double> REM_points;
  List<Alarm> alarms;
  List<String?> dream_signs;

  SleepData(this.bed_time, this.wake_time, this.REM_points, this.alarms, this.dream_signs);

  Map<String, dynamic> toJson() => {
    "bed_time": bed_time,
    "wake_time": wake_time,
    "REM_points": REM_points,
    "alarms": alarms.map((alarm) => alarm.toJson()).toList(),
    "dream_signs": dream_signs
  };

  factory SleepData.fromJson(Map<String, Object?> json) {
    List<dynamic> rem_data = json["REM_points"] as List<dynamic>;
    List<double> rem_points = rem_data.map((e) => (e as num).toDouble()).toList();
    List<dynamic> al_data = json["alarms"] as List<dynamic>;
    List<Alarm> al_list = al_data.map((item) => Alarm.fromJson(item)).toList();
    List<dynamic> signs_data = json["dream_signs"] as List<dynamic>;
    List<String?> dream_signs_l = signs_data.map((item) => item as String?).toList();

    return SleepData(
      json["bed_time"] as String?, 
      json["wake_time"] as String?, 
      rem_points,
      al_list,
      dream_signs_l
    );
  }
  
}

// ------------------------------------------------------------------------------------
// Alarm Class-------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Alarm  {
  String time;
  String tone;
  int duration;
  bool manual;
  bool active;

  Alarm(this.time, this.tone, this.duration, this.manual, this.active);

  Map<String, Object?> toJson() => {
    "time": time,
    "tone": tone,
    "duration": duration,
    "manual": manual,
    "active": active
  };

  factory Alarm.fromJson(Map<String, Object?> json) => Alarm(
    json["time"] as String,
    json["tone"] as String,
    json["duration"] as int,
    json["manual"] as bool,
    json["active"] as bool,
  );
}

// ------------------------------------------------------------------------------------
// Previous Night's Data Class---------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class LNData {
  int lucid;
  int recalled;
  List<String?> methods;
  List<Tone> v_logs;

  LNData(this.lucid, this.recalled, this.methods, this.v_logs);

  Map<String, dynamic> toJson() => {
    "lucid": lucid,
    "recalled": recalled,
    "methods": methods,
    "v_logs": v_logs.map((tone) => tone.toJson()).toList(),
  };

  factory LNData.fromJson(Map<String, Object?> json) {
    List<dynamic> methods_data = json["methods"] as List<dynamic>;
    List<String?> methods_l = methods_data.map((item) => item as String?).toList();
    List<dynamic> v_logs_data = json["v_logs"] as List<dynamic>;
    List<Tone> v_logs_l = v_logs_data.map((item) => Tone.fromJson(item as Map<String, Object?>)).toList();

    return LNData(
      json["lucid"] as int, 
      json["recalled"] as int,
      methods_l,
      v_logs_l
    );
  }
  
}

// ------------------------------------------------------------------------------------
// Achievement Class-------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Achievement  {
  final String title;
  final String description;
  bool completed;

  Achievement(this.title, this.description, this.completed);

  Map<String, Object?> toJson() => {
    "title": title,
    "description": description,
    "completed": completed
  };

  factory Achievement.fromJson(Map<String, Object?> json) => Achievement(
    json["title"] as String,
    json["description"] as String,
    json["completed"] as bool
  );
}

// ------------------------------------------------------------------------------------
// Tones Class-------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Tones {
  List<Tone> whitenoise;
  List<Tone> alarm;
  List<Tone> custom;

  Tones(this.whitenoise, this.alarm, this.custom);

  Map<String, dynamic> toJson() => {
    "whitenoise": whitenoise,
    "alarm": alarm,
    "custom": custom
  };

  factory Tones.fromJson(Map<String, Object?> json) {
    List<dynamic> whitenoise_data = json["whitenoise"] as List<dynamic>;
    List<Tone> whitenoise_l = whitenoise_data.map((item) => Tone.fromJson(item as Map<String, Object?>)).toList();
    List<dynamic> al_data = json["alarm"] as List<dynamic>;
    List<Tone> alarm_l = al_data.map((item) => Tone.fromJson(item as Map<String, Object?>)).toList();
    List<dynamic> custom_data = json["custom"] as List<dynamic>;
    List<Tone> custom_l = custom_data.map((item) => Tone.fromJson(item as Map<String, Object?>)).toList();

    return Tones(
      whitenoise_l,
      alarm_l,
      custom_l
    );
  }
  
}

// ------------------------------------------------------------------------------------
// Tone Class--------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class Tone {
  String name;
  String file;

  Tone(this.name, this.file);

  Map<String, dynamic> toJson() => {
    "name": name,
    "file": file,
  };

  factory Tone.fromJson(Map<String, Object?> json) => Tone (
    json["name"] as String,
    json["file"] as String
  );
  
}

// ------------------------------------------------------------------------------------
// Database Handler Class--------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
class DatabaseHandler {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'noxus.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_data (
        id INTEGER PRIMARY KEY,
        home INTEGER NOT NULL,
        journal INTEGER NOT NULL,
        log INTEGER NOT NULL,
        sleep INTEGER NOT NULL,
        tracker INTEGER NOT NULL,
        manuals INTEGER NOT NULL,
        last_active TEXT
      )
    ''');
    await db.insert('user_data', {
      'id': 1,
      'home': 0,
      'journal': 0,
      'log': 0,
      'sleep': 0,
      'tracker': 0,
      'manuals': 0,
      'last_active': ''
    });

    await db.execute('''
      CREATE TABLE stats (
        id INTEGER PRIMARY KEY,
        r_streak INTEGER NOT NULL,
        r_best INTEGER NOT NULL,
        l_count INTEGER NOT NULL,
        r_count INTEGER NOT NULL,
        app_streak INTEGER NOT NULL
      )
    ''');
    await db.insert('stats', {
      'id': 1,
      'r_streak': 0,
      'r_best': 0,
      'l_count': 0,
      'r_count': 0,
      'app_streak': 0
    });

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        rc_active INTEGER NOT NULL,
        ach_active INTEGER NOT NULL,
        rc_random INTEGER NOT NULL,
        rc_freq INTEGER NOT NULL,
        key_active INTEGER NOT NULL,
        wn_active INTEGER NOT NULL,
        whitenoise TEXT NOT NULL,
        passkey TEXT NOT NULL
      )
    ''');
    await db.insert('settings', {
      'id': 1,
      'rc_active': 0,
      'ach_active': 0,
      'rc_random': 0,
      'rc_freq': 3,
      'key_active': 1,
      'wn_active': 1,
      'whitenoise': 'classic.mp3',
      'passkey': ''
    });

    await db.execute('''
      CREATE TABLE sleep_data (
        id INTEGER PRIMARY KEY,
        bed_time TEXT,
        wake_time TEXT,
        rem_points TEXT NOT NULL,
        dream_signs TEXT NOT NULL
      )
    ''');
    await db.insert('sleep_data', {
      'id': 1,
      'bed_time': '22:00',
      'wake_time': '07:00',
      'rem_points': '[]',
      'dream_signs': '[]'
    });

    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT NOT NULL,
        tone TEXT NOT NULL,
        duration INTEGER NOT NULL,
        manual INTEGER NOT NULL,
        active INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ln_data (
        id INTEGER PRIMARY KEY,
        lucid INTEGER NOT NULL,
        recalled INTEGER NOT NULL,
        methods TEXT NOT NULL,
        v_logs TEXT NOT NULL
      )
    ''');
    await db.insert('ln_data', {
      'id': 1,
      'lucid': 0,
      'recalled': 0,
      'methods': '[]',
      'v_logs': '[]'
    });

    await db.execute('''
      CREATE TABLE achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');

    final achievementsList = [
      {"title": "Study Up", "description": "Read through the lucid dream technique manuals in the menu bar. "},
      {"title": "Journalist Beginner", "description": "Record five journal entries. "},
      {"title": "Recall Beginner", "description": "Recall one dream. "},
      {"title": "Awareness Beginner", "description": "Utilize reality check notifications. "},
      {"title": "Recall Student", "description": "Recall more than one dream in a single night. "},
      {"title": "Recall Intermediate", "description": "Recall 10 dreams. "},
      {"title": "Awareness Intermediate", "description": "Record one dream sign. "},
      {"title": "Lucid Beginner", "description": "Experience a lucid dream. "},
      {"title": "Persistence", "description": "Use Noxus for 30 days straight. "},
      {"title": "Journalist Intermediate", "description": "Record 50 journal entries. "},
      {"title": "Recall Proficient", "description": "Recall 50 dreams. "},
      {"title": "Lucid Intermediate", "description": "Experience 10 lucid dreams. "},
      {"title": "Awareness Advanced", "description": "Become lucid by using a reality check within the dream. "},
      {"title": "Recall Advanced", "description": "Recall 100 dreams. "},
      {"title": "Journalist Advanced", "description": "Record 100 journal entries. "},
      {"title": "Lucid Advanced", "description": "Experience 50 lucid dreams. "},
      {"title": "Awareness Master", "description": "Become lucid by recognizing a dream sign within the dream. "},
      {"title": "Recall Master", "description": "Recall 500 dreams. "},
      {"title": "Lucid Master", "description": "Experience 100 lucid dreams. "},
      {"title": "Journalist Master", "description": "Record 300 journal entries. "},
      {"title": "MILD", "description": "Experience one lucid dream using the MILD technique. "},
      {"title": "WBTB", "description": "Experience one lucid dream using the WBTB technique. "},
      {"title": "WILD", "description": "Experience one lucid dream using the WILD technique. "},
      {"title": "FILD", "description": "Experience one lucid dream using the FILD technique. "},
      {"title": "SSILD", "description": "Experience one lucid dream using the SSILD technique. "},
      {"title": "RAUSIS", "description": "Experience one lucid dream using the RAUSIS technique. "}
    ];

    for (var ach in achievementsList) {
      await db.insert('achievements', {
        'title': ach['title'],
        'description': ach['description'],
        'completed': 0,
      });
    }

    await db.execute('''
      CREATE TABLE tones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        name TEXT NOT NULL,
        file TEXT NOT NULL
      )
    ''');

    final defaultWhitenoise = [
      {"name": "None", "file": "none.mp3"},
      {"name": "Classic", "file": "classic.mp3"},
      {"name": "Forest Wind", "file": "forestWind.mp3"},
      {"name": "Ocean Waves", "file": "oceanWaves.mp3"},
      {"name": "Summer Rain", "file": "rain.mp3"},
      {"name": "Stream", "file": "stream.mp3"}
    ];
    for (var t in defaultWhitenoise) {
      await db.insert('tones', {'category': 'whitenoise', 'name': t['name'], 'file': t['file']});
    }

    final defaultAlarm = [
      {"name": "Bell Tower", "file": "bellTower.mp3"},
      {"name": "Beeping", "file": "beeping.mp3"},
      {"name": "Beeping 2", "file": "beeping2.mp3"},
      {"name": "Beeping 3", "file": "beeping3.mp3"},
      {"name": "Birds", "file": "birds.mp3"},
      {"name": "Classic", "file": "classic.mp3"},
      {"name": "Classic 2", "file": "classic2.mp3"},
      {"name": "Marimba", "file": "marimba.mp3"},
      {"name": "Owl", "file": "owl.mp3"},
      {"name": "Piano", "file": "piano.mp3"},
      {"name": "Windchimes", "file": "windchimes.mp3"},
      {"name": "Synth", "file": "synth.mp3"},
      {"name": "Old Phone", "file": "oldPhone.mp3"}
    ];
    for (var t in defaultAlarm) {
      await db.insert('tones', {'category': 'alarm', 'name': t['name'], 'file': t['file']});
    }

    await db.execute('''
      CREATE TABLE journal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        title TEXT,
        lucid INTEGER NOT NULL,
        content TEXT
      )
    ''');
  }

  Future<void> setUpDatabase() async {
    await database;
  }

  Future<UserData> readUserData() async {
    final db = await database;
    final maps = await db.query('user_data', where: 'id = 1');
    if (maps.isNotEmpty) {
      final row = maps.first;
      return UserData(
        (row['home'] as int) == 1,
        (row['journal'] as int) == 1,
        (row['log'] as int) == 1,
        (row['sleep'] as int) == 1,
        (row['tracker'] as int) == 1,
        (row['manuals'] as int) == 1,
        row['last_active'] as String?,
      );
    }
    return UserData(false, false, false, false, false, false, "");
  }

  Future<void> writeUserData(UserData data) async {
    final db = await database;
    await db.update(
      'user_data',
      {
        'home': data.home ? 1 : 0,
        'journal': data.journal ? 1 : 0,
        'log': data.log ? 1 : 0,
        'sleep': data.sleep ? 1 : 0,
        'tracker': data.tracker ? 1 : 0,
        'manuals': data.manuals ? 1 : 0,
        'last_active': data.last_active ?? '',
      },
      where: 'id = 1',
    );
  }

  Future<Stats> readStats() async {
    final db = await database;
    final maps = await db.query('stats', where: 'id = 1');
    if (maps.isNotEmpty) {
      final row = maps.first;
      return Stats(
        row['r_streak'] as int,
        row['r_best'] as int,
        row['l_count'] as int,
        row['r_count'] as int,
        row['app_streak'] as int,
      );
    }
    return Stats(0, 0, 0, 0, 0);
  }

  Future<void> writeStats(Stats data) async {
    final db = await database;
    await db.update(
      'stats',
      {
        'r_streak': data.r_streak,
        'r_best': data.r_best,
        'l_count': data.l_count,
        'r_count': data.r_count,
        'app_streak': data.app_streak,
      },
      where: 'id = 1',
    );
  }

  Future<Settings> readSettings() async {
    final db = await database;
    final maps = await db.query('settings', where: 'id = 1');
    if (maps.isNotEmpty) {
      final row = maps.first;
      return Settings(
        (row['rc_active'] as int) == 1,
        (row['ach_active'] as int) == 1,
        (row['rc_random'] as int) == 1,
        row['rc_freq'] as int,
        (row['key_active'] as int) == 1,
        (row['wn_active'] as int) == 1,
        row['whitenoise'] as String,
        row['passkey'] as String,
      );
    }
    return Settings(false, false, false, 3, true, true, "classic.mp3", "");
  }

  Future<void> writeSettings(Settings data) async {
    final db = await database;
    await db.update(
      'settings',
      {
        'rc_active': data.rc_active ? 1 : 0,
        'ach_active': data.ach_active ? 1 : 0,
        'rc_random': data.rc_random ? 1 : 0,
        'rc_freq': data.rc_freq,
        'key_active': data.key_active ? 1 : 0,
        'wn_active': data.wn_active ? 1 : 0,
        'whitenoise': data.whitenoise,
        'passkey': data.passkey,
      },
      where: 'id = 1',
    );
  }

  Future<List<Entry>> getEntries() async {
    final db = await database;
    final maps = await db.query('journal', orderBy: 'id ASC');
    return maps.map((row) {
      return Entry(
        row['date'] as String?,
        row['title'] as String?,
        (row['lucid'] as int) == 1,
        row['content'] as String?,
      );
    }).toList();
  }

  Future<void> postEntry(Entry data) async {
    final db = await database;
    await db.insert('journal', {
      'date': data.date,
      'title': data.title,
      'lucid': data.lucid ? 1 : 0,
      'content': data.content,
    });
  }

  Future<void> editEntry(int idx, Entry data) async {
    final db = await database;
    final maps = await db.query('journal', orderBy: 'id ASC');
    if (idx >= 0 && idx < maps.length) {
      int entryId = maps[idx]['id'] as int;
      await db.update(
        'journal',
        {
          'date': data.date,
          'title': data.title,
          'lucid': data.lucid ? 1 : 0,
          'content': data.content,
        },
        where: 'id = ?',
        whereArgs: [entryId],
      );
    }
  }

  Future<void> deleteEntry(int idx) async {
    final db = await database;
    final maps = await db.query('journal', orderBy: 'id ASC');
    if (idx >= 0 && idx < maps.length) {
      int entryId = maps[idx]['id'] as int;
      await db.delete(
        'journal',
        where: 'id = ?',
        whereArgs: [entryId],
      );
    }
  }

  Future<SleepData> readSleepData() async {
    final db = await database;
    final maps = await db.query('sleep_data', where: 'id = 1');
    List<double> remPoints = [];
    List<String?> dreamSigns = [];
    String? bedTime = "22:00";
    String? wakeTime = "07:00";

    if (maps.isNotEmpty) {
      final row = maps.first;
      bedTime = row['bed_time'] as String?;
      wakeTime = row['wake_time'] as String?;
      final remJson = row['rem_points'] as String? ?? '[]';
      final List<dynamic> remList = jsonDecode(remJson);
      remPoints = remList.map((e) => (e as num).toDouble()).toList();

      final signsJson = row['dream_signs'] as String? ?? '[]';
      final List<dynamic> signsList = jsonDecode(signsJson);
      dreamSigns = signsList.map((e) => e as String?).toList();
    }

    final alarmMaps = await db.query('alarms', orderBy: 'id ASC');
    List<Alarm> alarms = alarmMaps.map((row) {
      return Alarm(
        row['time'] as String,
        row['tone'] as String,
        row['duration'] as int,
        (row['manual'] as int) == 1,
        (row['active'] as int) == 1,
      );
    }).toList();

    return SleepData(bedTime, wakeTime, remPoints, alarms, dreamSigns);
  }

  Future<void> editSleepData(SleepData data) async {
    final db = await database;
    await db.update(
      'sleep_data',
      {
        'bed_time': data.bed_time,
        'wake_time': data.wake_time,
        'rem_points': jsonEncode(data.REM_points),
        'dream_signs': jsonEncode(data.dream_signs),
      },
      where: 'id = 1',
    );
    await db.delete('alarms');
    for (var alarm in data.alarms) {
      await db.insert('alarms', {
        'time': alarm.time,
        'tone': alarm.tone,
        'duration': alarm.duration,
        'manual': alarm.manual ? 1 : 0,
        'active': alarm.active ? 1 : 0,
      });
    }
  }

  Future<LNData> readLNData() async {
    final db = await database;
    final maps = await db.query('ln_data', where: 'id = 1');
    if (maps.isNotEmpty) {
      final row = maps.first;
      final methodsJson = row['methods'] as String? ?? '[]';
      final List<dynamic> methodsList = jsonDecode(methodsJson);
      final methods = methodsList.map((e) => e as String?).toList();

      final vLogsJson = row['v_logs'] as String? ?? '[]';
      final List<dynamic> vLogsList = jsonDecode(vLogsJson);
      final vLogs = vLogsList.map((e) => Tone.fromJson(e as Map<String, Object?>)).toList();

      return LNData(
        row['lucid'] as int,
        row['recalled'] as int,
        methods,
        vLogs,
      );
    }
    return LNData(0, 0, [], []);
  }

  Future<void> editLNData(LNData data) async {
    final db = await database;
    await db.update(
      'ln_data',
      {
        'lucid': data.lucid,
        'recalled': data.recalled,
        'methods': jsonEncode(data.methods),
        'v_logs': jsonEncode(data.v_logs.map((e) => e.toJson()).toList()),
      },
      where: 'id = 1',
    );
  }

  Future<void> postAlarm(Alarm al_data) async {
    final db = await database;
    await db.insert('alarms', {
      'time': al_data.time,
      'tone': al_data.tone,
      'duration': al_data.duration,
      'manual': al_data.manual ? 1 : 0,
      'active': al_data.active ? 1 : 0,
    });
  }

  Future<void> editAlarm(int idx, Alarm al_data) async {
    final db = await database;
    final alarmMaps = await db.query('alarms', orderBy: 'id ASC');
    if (idx >= 0 && idx < alarmMaps.length) {
      int alarmId = alarmMaps[idx]['id'] as int;
      await db.update(
        'alarms',
        {
          'time': al_data.time,
          'tone': al_data.tone,
          'duration': al_data.duration,
          'manual': al_data.manual ? 1 : 0,
          'active': al_data.active ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [alarmId],
      );
    }
  }

  Future<void> deleteAlarm(int idx) async {
    final db = await database;
    final alarmMaps = await db.query('alarms', orderBy: 'id ASC');
    if (idx >= 0 && idx < alarmMaps.length) {
      int alarmId = alarmMaps[idx]['id'] as int;
      await db.delete(
        'alarms',
        where: 'id = ?',
        whereArgs: [alarmId],
      );
    }
  }

  Future<List<Achievement>> getAchievements() async {
    final db = await database;
    final maps = await db.query('achievements', orderBy: 'id ASC');
    return maps.map((row) {
      return Achievement(
        row['title'] as String,
        row['description'] as String,
        (row['completed'] as int) == 1,
      );
    }).toList();
  }

  Future<void> editAchievements(List<Achievement> data) async {
    final db = await database;
    final maps = await db.query('achievements', orderBy: 'id ASC');
    for (int i = 0; i < data.length && i < maps.length; i++) {
      int achId = maps[i]['id'] as int;
      await db.update(
        'achievements',
        {
          'title': data[i].title,
          'description': data[i].description,
          'completed': data[i].completed ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [achId],
      );
    }
  }

  Future<Tones> readTones() async {
    final db = await database;
    final wnMaps = await db.query('tones', where: 'category = ?', whereArgs: ['whitenoise']);
    final alMaps = await db.query('tones', where: 'category = ?', whereArgs: ['alarm']);
    final cuMaps = await db.query('tones', where: 'category = ?', whereArgs: ['custom']);

    List<Tone> whitenoise = wnMaps.map((row) => Tone(row['name'] as String, row['file'] as String)).toList();
    List<Tone> alarm = alMaps.map((row) => Tone(row['name'] as String, row['file'] as String)).toList();
    List<Tone> custom = cuMaps.map((row) => Tone(row['name'] as String, row['file'] as String)).toList();

    return Tones(whitenoise, alarm, custom);
  }

  Future<void> editTones(Tones data) async {
    final db = await database;
    await db.delete('tones');
    for (var tone in data.whitenoise) {
      await db.insert('tones', {'category': 'whitenoise', 'name': tone.name, 'file': tone.file});
    }
    for (var tone in data.alarm) {
      await db.insert('tones', {'category': 'alarm', 'name': tone.name, 'file': tone.file});
    }
    for (var tone in data.custom) {
      await db.insert('tones', {'category': 'custom', 'name': tone.name, 'file': tone.file});
    }
  }
}