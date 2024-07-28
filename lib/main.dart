import 'package:flutter/material.dart';

void main() {
  runApp(MovableTextApp());
}

class MovableTextApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MovableTextPage(),
    );
  }
}

class MovableTextPage extends StatefulWidget {
  @override
  _MovableTextPageState createState() => _MovableTextPageState();
}

class _MovableTextPageState extends State<MovableTextPage> {
  TextEditingController _controller = TextEditingController();
  String selectedFont = 'Arial';
  Color selectedColor = Colors.black;
  double selectedFontSize = 18.0;

  final List<String> fonts = [
    'Arial',
    'Bahnschrift',
    'BookmanOldStyle',
    'CambriaMath',
    'SourceSansProLight',
    'ArialBlack',
  ];

  List<Map<String, dynamic>> texts = [];
  List<List<Map<String, dynamic>>> undoStack = [];
  List<List<Map<String, dynamic>>> redoStack = [];

  void saveState() {
    setState(() {
      undoStack.add(List<Map<String, dynamic>>.from(texts));
      redoStack.clear(); // Clear redo stack on new action
    });
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      setState(() {
        redoStack.add(List<Map<String, dynamic>>.from(texts));
        var lastState = undoStack.removeLast();
        texts = lastState;
      });
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      setState(() {
        undoStack.add(List<Map<String, dynamic>>.from(texts));
        var nextState = redoStack.removeLast();
        texts = nextState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text('Select Font', style: TextStyle(fontWeight: FontWeight.bold)),
              children: fonts.map((String font) {
                return ListTile(
                  title: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                  onTap: () {
                    setState(() {
                      saveState();
                      selectedFont = font;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                  },
                );
              }).toList(),
            ),
            ExpansionTile(
              title: Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.black),
                  title: Text('Black'),
                  onTap: () {
                    setState(() {
                      saveState();
                      selectedColor = Colors.black;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.red),
                  title: Text('Red'),
                  onTap: () {
                    setState(() {
                      saveState();
                      selectedColor = Colors.red;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue),
                  title: Text('Blue'),
                  onTap: () {
                    setState(() {
                      saveState();
                      selectedColor = Colors.blue;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green),
                  title: Text('Green'),
                  onTap: () {
                    setState(() {
                      saveState();
                      selectedColor = Colors.green;
                    });
                    Navigator.of(context).pop(); // Close the drawer
                  },
                ),
              ],
            ),
            ExpansionTile(
              title: Text('Select Size', style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                ListTile(
                  title: Slider(
                    value: selectedFontSize,
                    min: 10,
                    max: 50,
                    divisions: 40,
                    label: selectedFontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        saveState();
                        selectedFontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          ...texts.map((text) {
            return Positioned(
              left: text['position'].dx,
              top: text['position'].dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    text['position'] = Offset(text['position'].dx + details.delta.dx, text['position'].dy + details.delta.dy);
                  });
                },
                child: Text(
                  text['text'],
                  style: TextStyle(
                    fontFamily: text['font'],
                    color: text['color'],
                    fontSize: text['fontSize'],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
          Positioned(
            bottom: 50,
            left: 50,
            child: Row(
              children: [
                Container(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        saveState();
                        texts.add({
                          'position': Offset(100, 100),
                          'text': _controller.text,
                          'font': selectedFont,
                          'color': selectedColor,
                          'fontSize': selectedFontSize,
                        });
                        _controller.clear(); // Clear the text field after adding text
                      });
                    }
                  },
                  child: Text('Add Text'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 10,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: undoStack.isNotEmpty ? undo : null,
                ),
                IconButton(
                  icon: Icon(Icons.redo),
                  onPressed: redoStack.isNotEmpty ? redo : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
