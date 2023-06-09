import 'package:firebase_database/ui/firebase_animated_list.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Todo Application',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Todo List Application'),
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
// This method is rerun every time setState is called.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: Text(
          widget.title.toUpperCase(),
          textAlign: TextAlign.center,
        ),
      ),
      body: FirebaseAnimatedList(
          padding: const EdgeInsets.all(2),
          query: taskRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map task = snapshot.value as Map;
            task['key'] = snapshot.key;
            return _listTask(task: task);
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementTask,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add_task_outlined),
      ),
    );
  }

// function to go add task page
  void _incrementTask() {
// Open a new page and get a string from the user.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTask(), //GetStringFromUserPage(),
      ),
    );
  }

// create list of tasks from firebase
  Widget _listTask({required Map task}) {
    // defined task Icon on the left of the card
    Icon taskIcon = const Icon(Icons.task_outlined);
    if (task['status']) {
      taskIcon = const Icon(Icons.task);
    }

    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: taskIcon, //const Icon(Icons.task_outlined),
              title: Text(task['title']),
              subtitle: Text(task['description']),
              enabled: !task['status'],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // edit button
                IconButton(
                  onPressed: () {
                    // Open a new page and get a string from the user.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => const EditTask(task), //GetStringFromUserPage(),
                        builder: (context) => EditTaskScreen(tasKey: task['key'], taskTitle: task['title'], taskDescription: task['description'], taskStatus: task['status'],),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
                // delete button
                IconButton(
                  onPressed: () {
                    setState(() {
                      taskRef.child(task['key']).remove();
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
                const SizedBox(
                  width: 4,
                ),
                // status button
                Switch(
                  thumbIcon: thumbIcon,
                  value: task['status'],
                  onChanged: (bool value) {
                    setState(() {
                      task['status'] = value;
                      taskRef.child(task['key']).update({
                        'title': task['title'],
                        'description': task['description'],
                        'status': task['status']
                      });
                    });
                  },
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ],
        ),
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
      // get data from text fields
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

// create Edit task's page
class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.tasKey, required this.taskTitle, required this.taskDescription, required this.taskStatus});
  // Declare a field that holds the task key.
  final String tasKey;
  final String taskTitle;
  final String taskDescription;
  final bool taskStatus;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState(tasKey: tasKey, taskTitle: taskTitle, taskDescription: taskDescription, taskStatus: taskStatus);
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  _EditTaskScreenState({required this.tasKey, required this.taskTitle, required this.taskDescription, required this.taskStatus});

  final String tasKey;
  final String taskTitle;
  final String taskDescription;
  final bool taskStatus;

  final _formKey = GlobalKey<FormState>();
  // value for title & description
  TextEditingController _titleController =
      TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  // get database reference
  late DatabaseReference taskListRef =
      FirebaseDatabase.instance.ref('Tasks/$tasKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // for scrollable page
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text(
          'Edit Task',
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
                  // initialValue: taskTitle,
                  controller: _titleController = TextEditingController(text: taskTitle),
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
                  controller: _descriptionController = TextEditingController(text: taskDescription),
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
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                      // get data from text fields
                      final String title = _titleController.text;
                      final String description = _descriptionController.text;
                      // write on the database
                      taskListRef.set({
                        'title': title,
                        'description': description,
                        'status': taskStatus,
                      });

                      // go back to home
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTitle() {
    String taskTitle = '';
    taskListRef.child('title').onValue.listen((DatabaseEvent event) {
      final task = event.snapshot.value;
      taskTitle = task.toString();
    });

    return taskTitle;
  }
}
