import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  // initialize firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  // database  reference
  DatabaseReference taskRef = FirebaseDatabase.instance.ref('Tasks');
  

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
// Open a new page and get a string from the user.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTask(), //GetStringFromUserPage(),
      ),
    );
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
      ),
    );
  }
}

// create add task's page
class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  // value for title & description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  // get database reference
  DatabaseReference taskListRef = FirebaseDatabase.instance.ref('Tasks').push();
  // DatabaseReference newtaskRef = taskListRef.push();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // for scrollable page
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text(
          'Add New Task',
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // title input
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Task\'s title';
                    }
                    return null;
                  },
                  maxLength: 40,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.task_alt_sharp),
                    border: OutlineInputBorder(),
                    label: Text('Task\'s Title'),
                  ),
                ),
              ),
              // description input
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  minLines: 3,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.task_outlined),
                    border: OutlineInputBorder(),
                    labelText: 'Task\'s Description',
                  ),
                ),
              ),
              // submit button
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 20, 0, 10),
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // save info on database
  void _onSubmit() {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState!.validate()) {
      // Process data.
      // get data from textfields
      final String title = _titleController.text;
      final String description = _descriptionController.text;
      // write on the database
      taskListRef.set({
        'title': title,
        'description': description,
        'status': false,
      });

      // go back to home
      Navigator.pop(context);
    }
  }
}
