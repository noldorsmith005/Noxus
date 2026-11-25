// ------------------------------------------------------------------------------------
// Home Page --------------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Settings import
import 'package:noxus/menupages/settings.dart';
// Tutorials import
import 'package:noxus/menupages/tutorials.dart';
// User Guide import
import 'package:noxus/menupages/userguide.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';
// Main import
import 'package:noxus/main.dart';



class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  DatabaseHandler db = DatabaseHandler();
  final KeyField = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    Future<void> showDescription(Achievement achievement) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(achievement.title),
            content: Text(achievement.description),
            actions: <Widget>[
              TextButton(
                child: const Text("Got it", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.pop(context, 'Got it');
                },
              ),
            ],
          );
        },
      );
    }

    String calcAchP() {
      int comp = 0;
      for (var ach in appState.achievements) {
        if (ach.completed) {
          comp += 1;
        }
      }
      return "$comp/27";
    }
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 75.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(
          "Noxus",
          style: TextStyle(
            fontFamily: 'RougeScript',
            fontWeight: FontWeight.bold,
            fontSize: 55,
          )
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 40),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          if (appState.settings.key_active)
            IconButton(
              icon: const Icon(Icons.lock_outline, size: 28),
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
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shadowColor: Colors.white,
        elevation: 20,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: const SizedBox(),
              ),
            ),
            ListTile(
              title: const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage())
                );
              },
            ),
            ListTile(
              title: const Text("User Guide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              leading: Icon(Icons.description),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const UserGuide(),
                ));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text("Stats", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.35,
                          children: [
                            Card(
                              color: const Color.fromARGB(75, 200, 50, 255),
                              child: ListTile(
                                title: const Text("Recall Streak"),
                                subtitle: Text(
                                  "Current: ${appState.stats.r_streak} \nBest: ${appState.stats.r_best}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Card(
                              color: const Color.fromARGB(75, 50, 170, 255),
                              child: ListTile(
                                title: const Text("Lucid Count"),
                                subtitle: Text(
                                  "${appState.stats.l_count}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Card(
                              color: const Color.fromARGB(75, 50, 255, 75),
                              child: ListTile(
                                title: const Text("App Streak"),
                                subtitle: Text(
                                  "${appState.stats.app_streak}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Card(
                              color: const Color.fromARGB(75, 255, 245, 50),
                              child: ListTile(
                                title: const Text("Achievements"),
                                subtitle: Text(
                                  calcAchP(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Achievements
              Container(
                height: 400,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text("Achievements ", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      SizedBox(
                        height: 320,
                        width: 350,
                        child: ListView.builder(
                          itemCount: appState.achievements.length,
                          itemBuilder: (context, index) {
                            Achievement item = appState.achievements[index];
                            return SizedBox(
                              width: 300,
                              height: 85,
                              child: GestureDetector(
                                onTap: () {
                                  showDescription(item);
                                },
                                child: Card(
                                  color: Colors.transparent,
                                  shape: (item.completed)? RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.indigo, width: 1.5), 
                                    borderRadius: BorderRadius.circular(10.0), 
                                  ) : 
                                  RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey, width: 1.0), 
                                    borderRadius: BorderRadius.circular(10.0), 
                                  ),
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListTile(
                                      leading: (item.completed)? Icon(Icons.star, color: Colors.yellow[700]): Icon(Icons.star_border, color: Colors.grey),
                                      title: Text(item.title, style: TextStyle(fontSize: 17)),
                                    )
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Tutorials
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Tutorials())
                  );
                },
                child: Container(
                  height: 100,
                  width: 325,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 30),
                      Icon(Icons.menu_book, size: 50, color: const Color.fromARGB(255, 120, 125, 135)),
                      SizedBox(width: 20),
                      Text("Tutorials ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Spacer(),
                      Icon(Icons.chevron_right, size: 30, color: Colors.grey),
                      SizedBox(width: 20)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}