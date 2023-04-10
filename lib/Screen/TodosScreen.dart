// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final db = FirebaseFirestore.instance;
  DateTime dateTime = DateTime(2023, 04, 06);
  bool isChecked = true;
  int index = 0;
  bool unChecked = false;
  String? documentId;
  TimeOfDay timeOfDay = TimeOfDay.now();
  final selectedIndexes = <int>[];
  String? datetime;
  final CollectionReference Todos =
  FirebaseFirestore.instance.collection('Todos');

  Future _selectTime(BuildContext context) async {
    var time = await showTimePicker(
        context: context,
        initialTime: timeOfDay);

    if (time != null) {
      setState(() {
         datetime = "${time.hour}:${time.minute}";
      });
    }
  }

  Future<void> addStudent() async {
        await Todos.add({
      'todo_name': nameController.text,
      'todo_time':datetime,
    }).then((value) {
      setState(() {
        nameController.clear();
        datetime = null;
      });
    }).catchError((error) {
    });
  }

  void deleteSelectedDocuments(List<String> documentIds) async {
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
                  "Alaram Todos",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery
                          .of(context)
                          .size
                          .width / 10,
                      top: MediaQuery
                          .of(context)
                          .size
                          .height / 10,
                      right: MediaQuery
                          .of(context)
                          .size
                          .width / 10),
                  child: SingleChildScrollView(
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 50,
                              right: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 50),
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
                                        top: MediaQuery
                                            .of(context)
                                            .size
                                            .height / 55,
                                        left: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 33,
                                        right: MediaQuery
                                            .of(context)
                                            .size
                                            .width / 15),
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
                                  left: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 1.85,
                                  top: MediaQuery
                                      .of(context)
                                      .size
                                      .height / 100),
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
                                  left: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 1.6),
                              child: GestureDetector(
                                onTap: () async {
                                  await addStudent();
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
                              top: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 12),
                          child: Column(children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery
                                      .of(context)
                                      .size
                                      .width / 2),
                              child: const Text(
                                'Reminder',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
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
                                                    width: 3,
                                                    color: Color(0xFFBB1EF1)),
                                                checkColor: Colors.black,
                                                activeColor: const Color(
                                                    0xFFBB1EF1),
                                                controlAffinity:
                                                ListTileControlAffinity.leading,
                                                title: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                value: selectedIndexes.contains(
                                                    index),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value!) {
                                                      selectedIndexes.add(
                                                          index);
                                                    } else {
                                                      selectedIndexes.remove(
                                                          index);
                                                    }
                                                  });
                                                },
                                              );
                                            }),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .height /
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
                                                    color: const Color(
                                                        0xFF7F39A9),
                                                    width: 3)),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width /
                                                      30,
                                                  right: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width /
                                                      30),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  const Text("items",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight
                                                              .bold)),
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
                                                          fontWeight: FontWeight
                                                              .bold),
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
                      ]))),
            ),
          )),
    );
  }
}
