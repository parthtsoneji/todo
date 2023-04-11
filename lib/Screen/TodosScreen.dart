// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final db = FirebaseFirestore.instance;
  bool isChecked = true;
  int index = 0;
  String? documentId;
  TimeOfDay timeOfDay = TimeOfDay.now();
  final selectedIndexes = <int>[];
  String? datetime;
  final CollectionReference Todos =
      FirebaseFirestore.instance.collection('Todos');


    Future<void> _selectTime(BuildContext context) async {
      var time = await showTimePicker(context: context, initialTime: timeOfDay);

      if (time == null) {
        setState(() {
          time = TimeOfDay.now();
          datetime = "${time!.hour} : ${time!.minute}";
        });
      } else {
        String hour = time.hour.toString();
        String minute = time.minute.toString();
        if (hour.length >= 2 && minute.length >= 2) {
          setState(() {
            datetime = "${time!.hour} : ${time!.minute}";
          });
        } else if (hour.length < 2 && minute.length >= 2) {
          setState(() {
            datetime = "0${time!.hour} : ${time!.minute}";
          });
        } else if (hour.length >= 2 && minute.length < 2) {
          setState(() {
            datetime = "${time!.hour} : 0${time!.minute}";
          });
        } else {
          setState(() {
            datetime = "0${time!.hour} : 0${time!.minute}";
          });
        }
      }
    }

  Future<void> addTimer() async {
    String todoTime =
        datetime ?? "${TimeOfDay.now().hour} : ${TimeOfDay.now().minute}";
    await Todos.add({'todo_name': nameController.text, 'todo_time': todoTime})
        .then((value) {
      setState(() {
        nameController.clear();
        datetime = null;
      });
    }).catchError((error) {});
  }

  Future<void> deleteSelectedDocuments(List<String> documentIds) async {
    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance.collection('Todos');

    for (final id in documentIds) {
      final docRef = collectionRef.doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: const Color(0xFF131136),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              "Alarm Todos",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 10,
                  top: MediaQuery.of(context).size.height / 10,
                  right: MediaQuery.of(context).size.width / 10),
              child: SingleChildScrollView(
                  child: Column(children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 50,
                      right: MediaQuery.of(context).size.width / 50),
                  child: Stack(children: [
                    Container(
                        height: 50,
                        width: 500,
                        decoration: BoxDecoration(
                            color: const Color(0xFF2A2951),
                            borderRadius: BorderRadius.circular(25.0)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height / 55,
                                left: MediaQuery.of(context).size.width / 33,
                                right: MediaQuery.of(context).size.width / 15),
                            child: TextFormField(
                              controller: nameController,
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.white),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.circular(25.0)),
                                  hintStyle:
                                      const TextStyle(color: Colors.white),
                                  hintText: 'Create a new Todos...'),
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 1.95,
                          top: MediaQuery.of(context).size.height / 100),
                      child: GestureDetector(
                        onTap: () async {
                          _selectTime(context);
                        },
                        child: const Icon(Icons.timer_rounded,
                            color: Colors.white, size: 35),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 1.6),
                      child: GestureDetector(
                        onTap: () async {
                          await addTimer();
                        },
                        child: Container(
                          width: 80,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                          ),
                          child: const Center(
                            child: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 12),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 1.75),
                      child: const Text(
                        'Reminder',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                    Container(
                      height: 400,
                      width: 350,
                      color: const Color(0xFF2A2951),
                      child: Stack(children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Todos')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              final todos = snapshot.data!.docs;
                              return Stack(children: [
                                ListView.builder(
                                    itemCount: todos.length,
                                    itemBuilder: (context, index) {
                                      final todo = todos[index];
                                      return CheckboxListTile(
                                        checkboxShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        side: const BorderSide(
                                            width: 3, color: Color(0xFFBB1EF1)),
                                        checkColor: Colors.black,
                                        activeColor: const Color(0xFFBB1EF1),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              todo.data()['todo_name'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17),
                                            ),
                                            Text(
                                              todo
                                                  .data()['todo_time']
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                        value: selectedIndexes.contains(index),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value!) {
                                              selectedIndexes.add(index);
                                            } else {
                                              selectedIndexes.remove(index);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          2.2),
                                  child: Container(
                                    height: 40,
                                    width: 350,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        color: const Color(0xFF131136),
                                        boxShadow: const [
                                          BoxShadow(
                                              blurRadius: 15.0,
                                              color: Colors.white)
                                        ],
                                        border: Border.all(
                                            color: const Color(0xFF7F39A9),
                                            width: 3)),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context).size.width / 30,
                                          right: MediaQuery.of(context).size.width / 30),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              if (selectedIndexes.length == 1) {
                                                final todo = todos[selectedIndexes.first];
                                                final TextEditingController
                                                    nameController = TextEditingController(
                                                        text: todo.data()['todo_name']);
                                                final TextEditingController
                                                    timeController = TextEditingController(
                                                        text: todo.data()['todo_time']);

                                                final result = await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text('Edit Todo'),
                                                      content: Form(
                                                        child: Column(
                                                          mainAxisSize:MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              controller:nameController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      hintText:'Todo Name'),
                                                            ),
                                                            TextFormField(
                                                              controller:timeController,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      hintText:'Todo Time'),
                                                              onTap: () async {
                                                                await _selectTime(context);
                                                               setState(() {
                                                                 timeController.text = datetime!;
                                                               });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context,'Cancel');
                                                          },
                                                          child: const Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context,'Save');
                                                          },
                                                          child: const Text('Save'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (result == 'Save') {
                                                  final todoName =
                                                      nameController.text;
                                                  final todoTime =
                                                      timeController.text;
                                                  final todoId = todo.id;
                                                  FirebaseFirestore.instance
                                                      .collection('Todos')
                                                      .doc(todoId)
                                                      .update({
                                                    'todo_name': todoName,
                                                    'todo_time': todoTime,
                                                  });
                                                }
                                              }
                                              else{
                                                showDialog(context: context, builder: (context) {
                                                  return const Center(
                                                    child: AlertDialog(
                                                      title: Text("Select one to Edit"),
                                                      alignment: Alignment.center,
                                                    ),
                                                  );
                                                },);
                                              }
                                            },
                                            child: const Text("Edit",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              deleteSelectedDocuments(
                                                  selectedIndexes
                                                      .map((index) =>
                                                          todos[index].id)
                                                      .toList());
                                              setState(() {
                                                selectedIndexes.clear();
                                              });
                                            },
                                            child: const Text(
                                              "Clear Completed",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ]);
                            }
                          },
                        ),
                      ]),
                    ),
                  ]),
                ),
              ])),
          ),
        ),
      )),
    );
  }
}
