// ------------------------------------------------------------------------------------
// Tutorials Page ---------------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// DropCard import
import 'package:noxus/widgets/drop_card.dart';
// Main import
import 'package:noxus/main.dart';



class Tutorials extends StatefulWidget {
  const Tutorials({super.key});

  @override
  State<Tutorials> createState() => _TutorialsState();
}
class _TutorialsState extends State<Tutorials> {
  final List<bool> opened = List.filled(11, false);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    
    return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: Text("Tutorials", style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              DropCard(
                id: 0,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "Introduction to Lucid Dreaming ",
                content: "While you sleep, your brain undergoes multiple phases, which occur in cycles. Dreams occur during the REM (Rapid Eye Movement) phase. In normal dreams, your subconscious constructs the dream-world and its rules, reducing your sleeping conscious brain to the role of observer, and normally leaving little to no trace in your memory. However, through consistent practice and focus, a person is able to awaken their conscious brain while the rest of their body remains in a state of sleep in a phenomenon known as Lucid Dreaming. Over time, this leads to a great control over one's dreams and subconscious, opening up endless possibilities and adventures. This also serves as an incredible way to improve control over one's own mind and focus, and grow in the knowledge of oneself. This app aims to be your greatest toolkit in your journey towards mastery over your mind. In the following guides, you will learn more about the concepts, tools, and methods that have been used over the years, and take the first step of your Lucid Dreaming journey. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 1,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "Dream Journaling ",
                content: "In learning to control your dreams, the first step is memory. Most people have at least two dreams a night, but the vast majority only remember bits and pieces, or nothing at all. Remembering your dreams is necessary for effectively transporting your consciousness into the world your subconscious has created. This is because the process of remembering a dream when you wake up is eerily similar to remembering the waking world in your dream, due to the foggy state of your memory during sleep as it undergoes reconstruction. Maintaining a Dream Journal is an excellent way to remember your dreams. The use of writing for the purpose of committing something to memory is a long-held tradition, and it is especially applicable in this case. Even if you feel like you remember very little, if you can latch on to one little piece and begin writing, you are likely to prompt your memory into releasing more. In maintaining your Dream Journal, you should record every detail you can remember. Even the seemingly insignificant can be a great help in improving this ability. As well as improving your 'Dream Recall', the act of writing down your dreams sets the intention to experience a Lucid Dream, effectively creating a template for your subconscious to follow while sleeping, and drastically increasing your chances of it actually happening. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 2,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "Reality Checks ",
                content: "As well as improving your Dream Recall, you should also train yourself to subconsciously examine your surroundings on a regular basis. In the dream state, the typical rules of the waking world do not necessarily apply. As a result, many things should appear very strange to us, but since our consciousness is not active to analyze the environment and arrive at this conclusion, they do not. If we train our subconscious to constantly question its surroundings, then it will be constantly forced to prompt our consciousness. If this habit is deeply rooted enough, this prompting may activate our consciousness in the dream world as well as the waking, resulting in lucidity. As a side-effect, this practice also is greatly beneficial for improving focus and alertness. The notification features provided by this app can aid this process. There are benefits and drawbacks to both regular and irregular intervals in reality checks, so be sure to play around with the settings to determine which is more effective for you. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 3,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "Dream Signs ",
                content: "As you become more practiced and begin to recall more of your dreams, you will begin to notice patterns. Things such as places, people, scenarios, events, or even themes that reappear in one form or another across multiple dreams. You can even experience what I like to call 'Legacy Dreams': certain dreams which you have multiple times or continue the events of a previous dream. These will change over time, depending on what your mind is currently absorbed in. You can combine this with reality checks in real life, performing a reality check when you encounter a dream sign in the waking world. When you go to sleep, keep these in the forefront of your mind. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 4,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "Alarms ",
                content: "Alarms are an excellent tool for increasing your chances of experiencing a lucid dream. Every person has their own Sleep Cycle, which continues even while awake. The shorter the interval between when you fall asleep and when your dream begins the easier remembering the waking world will be. Since all dreams occur during REM sleep, pinpointing the times your REM phases occur, and then timing your sleep accordingly, will greatly increase your chances of becoming lucid. Set alarms throughout the night to narrow the REM window down. A good starting point is 4-6 hours after you first fall asleep. If you wake up to one of these alarms (or just on your own) and remember having a dream (even if you remember none of its content), log that occurrence in your Sleep Tracker page. This data will be used to populate your Dream Times map, which will then reflect when your peak dream times (and therefore likely REM phases) occur. Alarms are used as a part of specific methods, such as WBTB and RAUSIS. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 5,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The MILD Method ",
                content: "MILD (Mnemonic Induction of Lucid Dreams) is widely considered to be one of the best lucid dreaming methods for beginners, largely due to its simplicity and low time expenditure. To perform the MILD method, first select a phrase to remind you that you are lucid dreaming, such as 'This is a dream', 'I am dreaming', 'I will have a lucid dream tonight'. Avoid negations such as 'This is not real', as your subconscious may ignore negations. As you go to sleep, repeat this phrase over and over again in your head or out loud. Doing this helps set the intention and expectation in your subconscious mind to experience a lucid dream, and greatly increases the chances of this actually happening. As you continue to repeat your phrase over and over, begin to construct a dream-world in your mind. It can be anything. Picture yourself moving within and interacting with this dream world. Incorporate all your senses in this interaction. Continue this simulation and repetition of your phrase until you fall asleep. This method is often most effective when combined with the WBTB method. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 6,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The WBTB Method ",
                content: "The WBTB (Wake Back to Bed) method is a very simple method for increasing the effectiveness of most other lucid dreaming methods. To perform the WBTB method, you must plan to wake up at a certain point during the night. If you have been utilizing the Dream Heatmap in this app, set your alarm for 15-50 minutes (depending on how long it takes for you to fall asleep) before one of your dream hotspots. If you do not yet have sufficient data for this, a good starting point is approximately 4-6 hours after falling asleep (depending on your sleep schedule). From this point, you can experiment by setting alarms for different times and logging dream occurances in the Sleep Tracker to populate your Dream Heatmap. Once your alarm wakes you up, be sure to stay awake for 10-20 minutes. During this time, prepare your mind by writing in your Dream Journal, reviewing previous entries or Dream Signs, or anything else that keeps the intention to experience a lucid dream fresh in your mind. Once you go back to bed, this is your opportunity to incorporate your primary lucid dreaming method, such as MILD, WILD, or SSILD. Depending on your sleep schedule and sleep cycle, it is possible to perform WBTB multiple times a night. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 7,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The WILD Method ",
                content: "The WILD (Wake Induced Lucid Dreaming) method is largely held as the most difficult lucid dreaming method to perform, but also one of the most effective. To perform the WILD method, your goal is to remain in a conscious state while your body and subconscious fall asleep. Once you go to bed, get into a comfortable position. The best sleeping position simply depends on the person. It may be helpful to tailor this position so that none of your limbs are resting on any other parts of your body (legs crossed head on arm, etc. ). Once you have found a good sleeping position, the next step is to remain completely immobile. Restrain all reflexes such as swallowing, and do not move any part of your body. Clear your mind of any active thoughts, allowing it to wander, but devoting no attention to its passings. Simply let it all flow over your mind. Relax your muscles to relieve your body of any tension. You can adjust your position for this, or focus on one part of your body at a time, relaxing each in turn. Once you are relaxed, turn your attention to something such as your breathing, the sound of your heartbeat, or an ambient sound such as white noise. This is your 'anchor', the thing which you latch your mind onto in order to retain consciousness as your body sinks into sleep. After a while, you may feel strong vibrations running across your body. This is normal, and actually happens every night without you being aware of it. This is your brain testing to see if you are still awake before putting your body to sleep. Let these vibrations pass and pay them no attention. If you get to this point, you will soon enter Sleep Paralysis. This is also perfectly normal and happens every night as a preventative measure against you acting out the events of your dreams in the real world as you sleep. You will be unable to move (which you should not notice at this point since you are remaining still), but in the case where you try, find yourself unable to move, and panic, simply calm your mind and allow yourself to fall asleep, or remain alert and prompting your muscles long enough for your body to realize you are awake and the paralytic effects to wear off. If you pass this stage, you may see what is known as 'hypnagogic imagery', colors or shapes that you begin to see in the dark of your mind. This is your sleeping subconscious slowly beginning to render the dream world. After a few moments these shapes should become clearer until you find yourself standing in the dream, conscious and therefore lucid. Do not immediately attempt to interact with your environment. Instead, take it in through all your available senses and allow the dream a moment to stabilize. After another moment or two you may begin to move, but proceed slowly at first. Congratulations! You have successfully completed the most difficult lucid dreaming method. Combine this method with WBTB to maximize its effectiveness. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 8,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The FILD Method ",
                content: "The FILD (Finger Induced Lucid Dreaming) method is an extremely popular variant of the WILD method. Most steps align with the WILD method. Once you go to bed, begin moving your fingers very very slightly, as if playing piano. This action is both your anchor and also smooths the transition of your perception from the waking world to the dream. Do this while steadily decreasing the range of motion of your finger until it is no longer even a movement but a sensation of movement in your fingers. Complete from this point like the WILD method. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 9,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The SSILD Method ",
                content: "SSILD (Senses Initiated Lucid Dreaming) is a method that acts more as a preparation for sleep. Once you go to bed. Find a comfortable position. Like MILD, you are going to try to focus on sensory input. However, instead of creating a dream world and testing your senses there, focus on the real world. You should do this in cycles. First focus on sight, trying to pick out shapes and patterns in the darkness behind your eyelids. Then shift your attention to hearing, identifying any ambient sounds, your own breathing, distant noises, etc. Then on touch, noting sensations such as warmth or cold, the bed underneath you, your heartbeat, tension in your muscles, etc. You can do the same for the other senses as well, but these are the primary three. The order in which you do these does not matter, but cycle through them all about 5 times, spending no more than 30 seconds on each sense. Remember, this is about relaxing your body. If you cannot find any shapes or colors in your eyes, don't try too hard to make them appear. If you see nothing, focus on the darkness, if you notice shapes or patterns, focus on these, and similarly for the other senses. SSILD will often be used as a precursor to another method like FILD or WILD. ",
              ),
              SizedBox(height: 10),
              DropCard(
                id: 10,
                onExpanded: (id) {
                  opened[id] = true;
                  if (opened.every((val) => true)) {
                    appState.userData.manuals = true;
                    appState.persistUserData();
                  }
                },
                title: "The RAUSIS Method ",
                content: "The RAUSIS (Remember Awareness Until Sleep Is Successful) method is also a very easy method to perform, but takes some practice to set up correctly. It is used in tandem with WBTB. Once you wake up during the night to your WBTB alarm, do not try to remain awake, but instantly go back to sleep. You should be very sleepy at this point, but depending on how long it takes you to fall asleep, have another alarm set for 5-15 minutes after the first. This alarm should be intended not to wake you up, but to populate your dream world with something specific. For instance, setting the alarm tone to the sound of bells might spawn a bell tower in your dream. Since your mind was aware this sound was coming, it is likely that the sight and sound of this in the dream will trigger lucidity. Be very precise when setting this method up. Touchless alarms are best to reduce your time awake. The second alarm cannot be set too early or you will not be asleep yet, or too late or your mind may have let go of the expectation of that sound. It also cannot be too loud or too quiet, or else it will either wake you up or pass unnoticed. It may take a few tries for you to set up the method correctly, but it is extremely easy to perform and effective once you do. ",
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}