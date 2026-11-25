import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Hasher import
import 'package:noxus/utilities/bcrypthash.dart';

bool verifiyPin(Map<String, dynamic> params) {
  String entered = params["entered"];
  String pin = params["pin"];

  return Hasher.verifyPassword(entered, pin);
}

Widget pinCode(dynamic appState) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: PinCode(
        length: 4,
        title: "Enter Your Pin",
        pin: appState.settings.passkey,
        onCompleted: () async {
          await Future.delayed(Duration(milliseconds: 200));
          appState.unlockApp();
        },
      )
    ),
  );
}

Widget setupKey(dynamic appState) {
  return SetupKey(appState: appState);
}

class SetupKey extends StatefulWidget {
  const SetupKey({super.key, required this.appState});
  final dynamic appState;

  @override
  State<SetupKey> createState() => _SetupKeyState();
}

class _SetupKeyState extends State<SetupKey> {
  final _vaultKey = GlobalKey<FormState>();
  final _keyField = TextEditingController();

  @override
  void dispose() {
    _keyField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Form(
        key: _vaultKey,
        child: Column(
          children: [
            SizedBox(height: 100),
            Text("Set Your App Pin ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ListTile(
                title: TextFormField(
                  autofocus: true,
                  obscuringCharacter: '*',
                  obscureText: true,
                  controller: _keyField,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    hintText: 'Enter a 4-digit pin',
                  ),
                  validator: (value) {
                    List nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    for (var char in value.characters) {
                      if (!nums.contains(char)) {
                        return 'Invalid type. ';
                      }
                    }
                    if (value.length != 4) {
                      return 'Key must be 4 digits. ';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: ListTile(
                title: TextFormField(
                  autofocus: false,
                  obscuringCharacter: '*',
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    hintText: 'Confirm your pin',
                  ),
                  validator: (value) {
                    List nums = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    for (var char in value.characters) {
                      if (!nums.contains(char)) {
                        return 'Invalid type. ';
                      }
                    }
                    if (value.length != 4) {
                      return 'Key must be 4 digits. ';
                    }
                    if (value != _keyField.text) {
                      return 'Pins do not match. ';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (_vaultKey.currentState!.validate()) {
                  final hashed = Hasher.hashPassword(_keyField.text);
                  widget.appState.settings.passkey = hashed;
                  widget.appState.persistSettings();
                  _keyField.clear();
                  widget.appState.unlockApp();
                }
              }, 
              child: Text("Set Pin", style: TextStyle(color: Colors.white))
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("Be sure to remember your App Pin. If you forget your App Pin, you will likely permanently lose access to your data. "),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> authenticate(BuildContext context, dynamic appState) async {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "PINCODE",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) => Scaffold(
      body: Center(
        child: PinCode(
          length: 4,
          title: "Enter Your Pin",
          pin: appState.settings.passkey,
          onCompleted: () async {
            await Future.delayed(Duration(milliseconds: 200));
            if (context.mounted) {
              Navigator.pop(context, 'PINCODE');
            }
          },
        )
      ),
    ),
  );
}



class PinCode extends StatefulWidget {
  const PinCode({super.key, required this.length, required this.pin, required this.title, required this.onCompleted});
  final int length;
  final String pin;
  final String title;
  final Function onCompleted;

  @override
  State<PinCode> createState() => _PinCodeState();
}

class _PinCodeState extends State<PinCode> {
  String entered = "";
  bool show_error = false;

  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.all(30), 
        ),
        onPressed: () async {
          show_error = false;
          HapticFeedback.mediumImpact();
          if (entered.length < widget.length) {
            setState(() {
              entered += number.toString();
            });
          }
          if (entered.length == widget.length) {
            bool verified = await compute(verifiyPin, 
              { 
                'entered': entered,
                'pin': widget.pin,
              }
            );
            if (verified == true) {
              widget.onCompleted();
            }
            else {
              setState(() {
                entered = "";
                show_error = true;
              });
            }
          }
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(height: 30),
            Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: (show_error)? Text(
                "Invalid Pin",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ) : null
            ),
            (show_error == false)? SizedBox(height: 50) : SizedBox(height: 29),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.length,
                (index) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: (index < entered.length)? 
                        CupertinoColors.white :
                        CupertinoColors.systemGrey.withValues(alpha: 0.2),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => numButton(1 + 3 * i + index),
                  ).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextButton(onPressed: null, child: SizedBox()),
                  numButton(0),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (entered.isNotEmpty) {
                          entered = entered.substring(0, entered.length - 1);
                        }
                      });
                    },
                    child: const Icon(
                      Icons.backspace,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}