// ------------------------------------------------------------------------------------
// Dream Journal Page -----------------------------------------------------------------
// ------------------------------------------------------------------------------------ 
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// Main import
import 'package:noxus/main.dart';
// Event Display import
import 'package:noxus/subpages/enrtyview.dart';
// Database import
import 'package:noxus/utilities/dbinterface.dart';




class Journal extends StatefulWidget {
  @override
  State<Journal> createState() => _JournalState();

}
class _JournalState extends State<Journal> {
  DatabaseHandler db = DatabaseHandler();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _filterIndex = 0; // 0: All, 1: Lucid, 2: Non-Lucid

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    void refresh() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }

    Future deleteEntry(int index) async {
      appState.entries.removeAt(index);
      db.deleteEntry(index);
      if (context.mounted) {
        Navigator.pop(context, 'Delete');
      }
      refresh();
    }

    Future<void> deleteAlert(int index) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, 
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Warning"),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("This action cannot be undone and the entry will be unrecoverable. "),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context, 'Cancel'),
              ),
              TextButton(
                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  deleteEntry(index);
                },
              ),
            ],
          );
        },
      );
    }
    

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar (
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        scrolledUnderElevation: 0.0,
        title: const Text("Dream Journal", style: TextStyle(fontWeight: FontWeight.bold)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          if (appState.entries.length >= 300) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Journal Entry storage limit reached. Please export your journal."),
              duration: Duration(seconds: 2),
            ));
          }
          else {
            final DateTime now = DateTime.now();
            final DateFormat formatter = DateFormat('MM/dd/yyyy');
            final String formatted = formatter.format(now);
            JEntry blank_entry = JEntry(-1, formatted, "", false, "");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EntryView(entry: blank_entry, RefreshEntries: refresh))
            );
          }
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 10, 30, 80),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        tooltip: "New Entry",
        child: const Icon(Icons.post_add_outlined)
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim().toLowerCase();
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search dreams...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color.fromARGB(140, 20, 20, 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.purple.withValues(alpha: 0.2), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("All"),
                      labelStyle: TextStyle(color: _filterIndex == 0 ? Colors.white : Colors.white70, fontWeight: _filterIndex == 0 ? FontWeight.bold : FontWeight.normal),
                      selected: _filterIndex == 0,
                      selectedColor: Colors.purple.withValues(alpha: 0.4),
                      backgroundColor: const Color.fromARGB(90, 20, 20, 20),
                      side: BorderSide(color: _filterIndex == 0 ? Colors.purpleAccent : Colors.transparent, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) setState(() => _filterIndex = 0);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Lucid Only"),
                      labelStyle: TextStyle(color: _filterIndex == 1 ? Colors.white : Colors.white70, fontWeight: _filterIndex == 1 ? FontWeight.bold : FontWeight.normal),
                      selected: _filterIndex == 1,
                      selectedColor: Colors.purple.withValues(alpha: 0.4),
                      backgroundColor: const Color.fromARGB(90, 20, 20, 20),
                      side: BorderSide(color: _filterIndex == 1 ? Colors.purpleAccent : Colors.transparent, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) setState(() => _filterIndex = 1);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Non-Lucid"),
                      labelStyle: TextStyle(color: _filterIndex == 2 ? Colors.white : Colors.white70, fontWeight: _filterIndex == 2 ? FontWeight.bold : FontWeight.normal),
                      selected: _filterIndex == 2,
                      selectedColor: Colors.purple.withValues(alpha: 0.4),
                      backgroundColor: const Color.fromARGB(90, 20, 20, 20),
                      side: BorderSide(color: _filterIndex == 2 ? Colors.purpleAccent : Colors.transparent, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) setState(() => _filterIndex = 2);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                List<Entry> allEntries = appState.entries;
                if (allEntries.isEmpty) {
                  return Center(child: Text("No entries yet", style: TextStyle(color: Colors.grey, fontSize: 18)));
                }

                // Filter entries with their original index maintained
                List<int> filteredIndices = [];
                for (int i = (allEntries.length - 1); i >= 0; i--) {
                  Entry item = allEntries[i];
                  
                  // Lucidity filter check
                  if (_filterIndex == 1 && !item.lucid) continue;
                  if (_filterIndex == 2 && item.lucid) continue;

                  // Search query check
                  if (_searchQuery.isNotEmpty) {
                    String titleStr = (item.title ?? '').toLowerCase();
                    String contentStr = (item.content ?? '').toLowerCase();
                    if (!titleStr.contains(_searchQuery) && !contentStr.contains(_searchQuery)) {
                      continue;
                    }
                  }

                  filteredIndices.add(i);
                }

                if (filteredIndices.isEmpty) {
                  return Center(child: Text("No matching entries found", style: TextStyle(color: Colors.grey, fontSize: 16)));
                }

                return ListView.builder(
                  itemCount: filteredIndices.length,
                  itemBuilder: (context, idx) {
                    int originalIndex = filteredIndices[idx];
                    Entry currEntry = allEntries[originalIndex];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Slidable(
                            startActionPane: ActionPane(
                              motion: const StretchMotion(), 
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: (currEntry.lucid)? Icons.visibility_off: Icons.visibility,
                                  label: "Toggle Lucidity",
                                  onPressed:(context) async {
                                    currEntry.lucid = !currEntry.lucid;
                                    await db.editEntry(originalIndex, currEntry);
                                    refresh();
                                  },
                                )
                              ]
                            ),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(), 
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: "Delete",
                                  onPressed:(context) {
                                    deleteAlert(originalIndex);
                                  },
                                )
                              ]
                            ),
                            child: ListTile(
                              leading: (currEntry.lucid)? Icon(Icons.visibility_outlined, color: Colors.blue): null,
                              title: Text(currEntry.title as String),
                              subtitle: Text(currEntry.date as String),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                JEntry target = JEntry(originalIndex, currEntry.date as String, currEntry.title as String, currEntry.lucid, currEntry.content as String);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EntryView(entry: target, RefreshEntries: refresh))
                                );
                              },
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 0.5,
                          indent: 10,
                          endIndent: 10,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    );
                  },
                );
              }
            ),
          ),
        ],
      )
    );
  }
}