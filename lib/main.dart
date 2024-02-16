import 'package:flutter/material.dart';
import 'database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the new page when the button is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondPage()),
            );
          },
          child: Text('Open New Page'),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final dbHelper = DatabaseHelper();
  List<String> itemList = []; // List to store items
  String addValue = "";

  @override
  void initState() {
    super.initState();
    fetchData();
    print("List data: $itemList");
  }

  Future<void> fetchData() async {
    List<String> dbItems = await dbHelper.getItems();
    setState(() {
      itemList.addAll(dbItems);
    });
  }

  Future<void> deleteData() async {
    await dbHelper.deleteItem(itemList[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(itemList[index]),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              deleteData();
            },
            child: Text('Delete Item'),
          ),
          ElevatedButton(
            onPressed: () {
              // Show a dialog to get a new item from the user
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add New Item'),
                    content: TextField(
                      onChanged: (value) {
                        addValue = value;
                        // Update the value as the user types
                        // setState(() {
                        //   // Add the new item to the list
                        //   itemList.add(value);
                        // });
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            // Add the new item to the list
                            itemList.add(addValue);
                            dbHelper.insertItem(addValue);
                          });
                          // Close the dialog and add the new item
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Add New Item'),
          ),
        ],
      ),
    );
  }
}
