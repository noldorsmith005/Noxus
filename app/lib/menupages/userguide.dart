// ------------------------------------------------------------------------------------
// User Guide Page --------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Main import
import 'package:noxus/main.dart';
// DropCard import
import 'package:noxus/widgets/drop_card.dart';



class UserGuide extends StatefulWidget {
  const UserGuide({super.key});

  @override
  State<UserGuide> createState() => _UserGuideState();
}
class _UserGuideState extends State<UserGuide> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    
    return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: Text("User Guide", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: BackButtonIcon(),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          }, 
        ),
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropCard(
                        title: "Welcome page",
                        content: "The Welcome page is where your dream statistics and achievements are displayed. First are your statistics: Current Recall Streak, Best Recall Streak, Lucid Dream Count, App Streak, and Completed Achievements. Next is a list of all achievements, with the ones you have completed marked. You can view the requirements for completing each achievement by clicking on it. There are 26 achievements in total. ",
                      ),
                      SizedBox(height: 10),
                      DropCard(
                        title: "Dream Journal",
                        content: "Your Dream Journal is one of your most powerful tools in your Lucid Dreaming journey. Click the button on the bottom right of the screen to create your dream journal for the previous night. You may create one journal entry per day. Journal entries are automatically locked with a key which you create upon attempting to open your first journal. This key can be deactivated or changed in settings. You can also recover access to your journal should you forget your key, but keep in mind that this will delete all current entries. Sliding a journal entry to the left gives you the option to delete that entry. Sliding a journal entry to the right gives you the option to mark that entry as containing a lucid dream (This has no effect on your data, which is controlled by your nightly Sleep Summaries, and is simply a helpful visual). In-app journal entry storage is limited to 300 entries at a time. You may clear your in-app storage at any time by exporting your entries to a PDF file from settings. ",
                      ),
                      SizedBox(height: 10),
                      DropCard(
                        title: "Sleep Data",
                        content: "The Sleep Data page stores your Dream Heatmap, recorded Dream Signs, and recorded data from the previous night's Sleep Summary. Your Dream Heatmap is available after logging 10 dream occurrences (pulled from your Sleep Tracker). It takes the timestamps of those occurrences and maps them onto a graph in order to visually represent which times mark your peak dream time during the night. You should use this data for setting your nightly alarms if using methods such as WBTB or RAUSIS. Your Dream Heatmap data can be reset from settings. Your Dream Signs are manually logged, the purpose of these is explained in the Tutorials section of this app. These are displayed for easy reference on your Sleep Tracker page to keep them fresh in your mind. You may log up to 5 dreams signs at a time, as attempting to remember too many reduces their effectiveness. Your Sleep Summary from the previous night is also displayed on this page, and displays total lucid dreams experienced, total dreams recalled, and any methods you used. ",
                      ),
                      SizedBox(height: 10),
                      DropCard(
                        title: "Sleep",
                        content: "The Sleep page stores your sleep schedule, nightly alarms, and Sleep Tracker. Your sleep schedule can be edited at any time, but keep in mind that a consistent sleep schedule is optimal for maximizing the effectiveness of most lucid dreaming methods. If you change your sleep schedule, you should reset your Dream Heatmap data from settings, as the peak dream times reflected there will likely change to align with your new sleep schedule. Similarly, if for whatever reason there is a small time frame where you are unable to follow your sleep schedule but do not wish to permanently change it, simply refrain from logging dream occurrences until you return to your schedule and your body readjusts. Your Alarms are another powerful tool for many lucid dreaming techniques. View an alarm by pressing it. In the single alarm view, alarms can be set to time-out automatically in a range of 10 to 60 seconds, or be manually stopped. There are many alarm tone presets you may choose from, as well as creating your own custom recorded alarm tones in settings. Alarms are also deleted from this page. Back on the main sleep page, the toggle on the right of the alarm activates it. The Sleep Tracker is launched by pressing the blue button in the center of the Sleep page, and then pressing the green 'Start' button at the bottom of the Sleep Tracker page. Once launched, your white noise audio will begin playing and all activated alarms will be queued. Your white noise audio can be changed or turned off from settings. The white noise audio will be temporarily interrupted by any external media such as phone calls, and will likely override all other local audio, and will keep playing until the Sleep Tracker is closed. NOTE: DUE TO iOS SYSTEM SECURITY, THE SLEEP TRACKER WILL CANCEL UPON CLOSING THE APP. YOU MAY NAVIGATE TO ANY OTHER PAGE OF THIS APP, RETURN TO THE HOMESCREEN, OPEN OTHER APPS, AND POWER OFF YOUR DEVICE SCREEN, BUT KEEP THIS APP RUNNING IN THE BACKGROUND WHILE THE SLEEP TRACKER IS RUNNING. Once launched, you may log dream occurrences during the night by pressing and holding the purple 'Log' button at the bottom of the page. It should also be noted that your Dream Heatmap caps off at a certain point to avoid redundant data, so keep in mind that after a couple weeks of consistent dream occurrence logging, you do not need to continue. Your Dream Signs recorded in the Sleep Data page are also displayed here. Once your sleep is completed, press the red 'End' button at the top right of the page to open your Sleep Summary log. Here you can enter the amount of recalled dreams, lucid dreams, and lucid dreaming methods you used during the night, before exiting and terminating the Sleep Tracker session. If for whatever reason you wish to terminate the Sleep Tracker session without logging data, simply select the 'Skip' button instead of the 'End' button. ",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}