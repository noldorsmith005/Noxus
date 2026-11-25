import 'package:flutter/material.dart';



class DropCard extends StatefulWidget {
  const DropCard({super.key, this.id=0, required this.title, required this.content, this.onExpanded});
  final int id;
  final String title;
  final String content;
  final Function? onExpanded;

  @override
  State<DropCard> createState() => _DropCardState();
}

class _DropCardState extends State<DropCard> {
  bool expanded = false;

  void toggle() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onExpanded?.call(widget.id);
        toggle();
      },
      child: Card(
        color: const Color.fromARGB(100, 80, 80, 80),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.title, style: TextStyle(fontSize: 17)),
              trailing: (expanded) ? Icon(Icons.expand_more) : Icon(Icons.chevron_right),
            ),
            (expanded) ? 
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("     ${widget.content}", style: TextStyle(fontSize: 15)),
              )
            ) : 
            SizedBox(),
          ],
        ),
      ),
    );
  }
}