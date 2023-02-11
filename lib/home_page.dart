import 'package:flutter/material.dart';
import 'package:gpa_center/semester_page.dart';

import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SqlDb dbHelper = SqlDb();

  Future<List<Map>> semester() => dbHelper.getSemesterData();
  Future<List<Map>> cumulative() => dbHelper.getCumulativeData();

  var formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPA center"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          showDialog(
            context: context,
            builder: (context) {
              return Form(
                key: formKey,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text("Add New Semester"),
                  content: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Semester Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Semester Name must not be empty';
                        }
                        return null;
                      }),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            dbHelper.insertSemester(
                                semesterName: nameController.text);
                          });
                          nameController.clear();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Done"),
                    )
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: semester(),
        builder: (context, AsyncSnapshot<List<Map>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text("No semesters was added yet"));
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: cumulative(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map>> cumulativeSnapshot) {
                            if (cumulativeSnapshot.hasData) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Cumulative Grade",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color(0xFFE8D7FF),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "${cumulativeSnapshot.data![0]["grade"]}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Cumulative GPA",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: const Color(0xFFE8D7FF),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "${cumulativeSnapshot.data![0]["GPA"]}",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async{
                                String value = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SemesterPage(
                                      id: snapshot.data![index]["id"],
                                      semesterName: snapshot.data![index]
                                          ["semester_name"],
                                    ),
                                  ),
                                );
                                setState(() {
                                  
                                });
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24.0)),
                                  ),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return (Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Container(
                                          height: 4,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          onTap: () async{
                                            Navigator.of(context).pop();
                                            String value = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SemesterPage(
                                                  semesterName:
                                                      snapshot.data![index]
                                                          ["semester_name"],
                                                  id: snapshot.data![index]
                                                      ["id"],
                                                ),
                                              ),
                                            );
                                            setState(() {
                                              
                                            });
                                          },
                                          leading: const Icon(Icons
                                              .format_list_bulleted_outlined),
                                          title: const Text("Show Details"),
                                        ),
                                        const SizedBox(height: 8),
                                        ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
    
                                              nameController.text =
                                                  snapshot.data![index]
                                                      ["semester_name"];
    
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Form(
                                                    key: formKey,
                                                    child: AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      title: Text(
                                                          "Edit ${snapshot.data![index]["semester_name"]}"),
                                                      content: TextFormField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'Semester Name',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Semester Name must not be empty';
                                                            }
                                                            return null;
                                                          }),
                                                      actions: [
                                                        FilledButton(
                                                          onPressed: () {
                                                            if (formKey
                                                                .currentState!
                                                                .validate()) {
                                                              setState(
                                                                () {
                                                                  dbHelper
                                                                      .updateSemester(
                                                                    semesterName:
                                                                        nameController
                                                                            .text,
                                                                    id: snapshot
                                                                            .data![index]
                                                                        [
                                                                        "id"],
                                                                  );
                                                                },
                                                              );
                                                              nameController
                                                                  .clear();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }
                                                          },
                                                          child: const Text(
                                                              "Done"),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            leading: const Icon(Icons.edit),
                                            title: Text(
                                                "Edit ${snapshot.data![index]["semester_name"]}")),
                                        const SizedBox(height: 8),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(
                                                title: Text(
                                                    "Delete ${snapshot.data![index]["semester_name"]}"),
                                                content: const Text(
                                                  "Are you sure you want to delete this semeter?\nThis will also delete all related courses and you will be not able to recover them again",
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: [
                                                  FilledButton(
                                                    onPressed: () {
                                                      dbHelper.deleteSemester(
                                                          snapshot.data![
                                                              index]["id"]);
                                                      setState(() {});
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                        backgroundColor:
                                                            Color(0xFFE8D7FF),
                                                        content:
                                                            Text("Deleted!"),
                                                        duration: Duration(
                                                            seconds: 1),
                                                      ));
                                                    },
                                                    child: const Text("Yes"),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("No"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          leading: const Icon(Icons.delete,
                                              color: Colors.red),
                                          title: const Text("Delete"),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ));
                                  },
                                );
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA188C0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${snapshot.data![index]["semester_name"]}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: const Color(0xFFE8D7FF),
                                          ),
                                          child: Center(
                                              child: Text(
                                            "${snapshot.data![index]["grade"]}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          )),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Container(
                                          height: 20,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: const Color(0xFFE8D7FF),
                                          ),
                                          child: Center(
                                              child: Text(
                                            "${snapshot.data![index]["GPA"]}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 24),
                          itemCount: snapshot.data!.length,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
