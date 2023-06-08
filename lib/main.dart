import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  // initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // DatabaseReference postListRef = FirebaseDatabase.instance.ref("posts");
  // DatabaseReference newPostRef = postListRef.push();
  // newPostRef.set({
  //   'Task':'Yes',
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Application',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Todo List Appllication'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool light = false;
  // count number of task
  int counter = 0;
  // list of tasks
  final tasks = [];
  // database refrence
  // FirebaseDatabase database = FirebaseDatabase.instance;
  // DatabaseReference databaseRef =
  //     FirebaseDatabase.instance.ref('Tasks/');

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];

  void _incrementTask() {
    // tasks.add({
    //   'title': 'Task $_counter',
    //   'description': 'This is the description for Task $_counter.',
    //   'complete': false,
    // });
    // setState(() {
    //   databaseRef.set(tasks);
    //   _counter++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
          child: Text(
            widget.title.toUpperCase(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(2),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Task\'s Title'),
                      subtitle: Text('Task\'s Description'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Switch(
                          thumbIcon: thumbIcon,
                          value: light,
                          onChanged: (bool value) {
                            setState(() {
                              light = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementTask,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add_task_outlined),
        // tooltip: _counter.toString(),
      ),
    );
  }
}
