// ------------------------------------------------------------------------------------
// Journal Entry View Page ------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// Main import
import 'package:noxus/main.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';


class JEntry {
  int index;
  String date;
  String title;
  bool lucid;
  String content;

  JEntry(this.index, this.date, this.title, this.lucid, this.content);
}


class EntryView extends StatefulWidget {
  const EntryView({super.key, required this.entry, required this.RefreshEntries});
  final JEntry entry;
  final Function RefreshEntries;

  @override
  State<EntryView> createState() => _EntryViewState();
}

class _EntryViewState extends State<EntryView> {
  DatabaseHandler db = DatabaseHandler();
  final ScrollController sController = ScrollController();
  final FocusNode tNode = FocusNode();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool _speechEnabled = false;
  String _baseContent = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    _speech = stt.SpeechToText();
    _initSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sController.jumpTo(0.0);
      if (widget.entry.index == -1) {
        tNode.requestFocus();
      }
    });
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
        onError: (errorNotification) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechEnabled = available;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _speechEnabled = false;
        });
      }
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      if (!_speechEnabled) {
        _initSpeech();
      }

      if (_speechEnabled) {
        _baseContent = _contentController.text;
        if (_baseContent.isNotEmpty && !_baseContent.endsWith(' ') && !_baseContent.endsWith('\n')) {
          _baseContent += ' ';
        }

        setState(() {
          _isListening = true;
        });

        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                String recognized = result.recognizedWords;
                String updated = _baseContent + recognized;
                _contentController.text = updated;
                _contentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: updated.length),
                );
                widget.entry.content = updated;
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
          ),
        );

      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Speech recognition unavailable or microphone permission denied."),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _titleController.dispose();
    _contentController.dispose();
    sController.dispose();
    tNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              String titleText = _titleController.text.trim();
              widget.entry.title = titleText.isEmpty ? "Untitled Dream" : titleText;
              widget.entry.content = _contentController.text;
              Entry new_entry = Entry(
                widget.entry.date,
                widget.entry.title,
                widget.entry.lucid,
                widget.entry.content,
              );
              if (widget.entry.index == -1) {
                appState.entries.add(new_entry);
                db.postEntry(new_entry);
              } else {
                appState.entries[widget.entry.index] = new_entry;
                db.editEntry(widget.entry.index, new_entry);
              }
              if (context.mounted) {
                Navigator.pop(context);
                widget.RefreshEntries();
              }
            },
            child: const Text("Save", style: TextStyle(fontSize: 18, color: Colors.blue)),
          ),
        ],
        flexibleSpace: GestureDetector(
          onDoubleTap: () {
            appState.lockApp();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleListening,
        backgroundColor: _isListening ? Colors.redAccent : const Color.fromARGB(255, 10, 30, 80),
        foregroundColor: Colors.white,
        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
        label: Text(
          _isListening ? "Listening..." : "Record",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          tNode.requestFocus();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: sController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: TextFormField(
                          controller: _titleController,
                          cursorColor: Colors.white,
                          maxLength: 30,
                          cursorHeight: 30,
                          maxLines: 2,
                          showCursor: true,
                          expands: false,
                          autofocus: false,
                          autocorrect: false,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (value) {
                            widget.entry.title = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          controller: _contentController,
                          focusNode: tNode,
                          cursorColor: Colors.white,
                          showCursor: true,
                          maxLength: null,
                          maxLines: null,
                          expands: false,
                          autofocus: false,
                          autocorrect: true,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            widget.entry.content = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}