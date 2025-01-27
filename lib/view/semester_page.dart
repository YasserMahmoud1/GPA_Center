import 'package:flutter/material.dart';

import '../core/database/database_helper.dart';

class SemesterPage extends StatefulWidget {
  const SemesterPage({super.key, required this.id, required this.semesterName});
  final int id;
  final String semesterName;

  @override
  State<SemesterPage> createState() =>
      _SemesterPageState(id: id, semesterName: semesterName);
}

class _SemesterPageState extends State<SemesterPage> {
  _SemesterPageState({required this.id, required this.semesterName});
  final int id;
  final String semesterName;

  DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<Map>> course() => dbHelper.getCourseData(id);
  Future<List<Map>> total() => dbHelper.getSemesterGradeData(id);

  var formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();

  var creditHoursController = TextEditingController();

  var percentageController = TextEditingController();

  double getGrade(String percentage) {
    double p = double.parse(percentage);
    if (p >= 90) {
      return 4;
    } else if (p >= 85) {
      return 3.6;
    } else if (p >= 80) {
      return 3.3;
    } else if (p >= 75) {
      return 3;
    } else if (p >= 70) {
      return 2.6;
    } else if (p >= 65) {
      return 2.4;
    } else if (p >= 60) {
      return 2.2;
    } else if (p >= 50) {
      return 2;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "true");
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(semesterName),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            nameController.clear();
            creditHoursController.clear();
            percentageController.clear();
            showDialog(
              context: context,
              builder: (context) {
                return Form(
                  key: formKey,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Add New Course"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Course Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Coutse Name must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: creditHoursController,
                          decoration: const InputDecoration(
                            labelText: 'Credit Hours',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Credit Hours must not be empty';
                            } else if (int.tryParse(value) == null) {
                              return 'Credit Hours must be integer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: percentageController,
                          decoration: const InputDecoration(
                            labelText: 'Percentage',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Percentage must not be empty';
                            } else if (double.tryParse(value) == null) {
                              return 'Percentage must be double';
                            } else if (double.parse(value) > 100 ||
                                double.parse(value) < 0) {
                              return 'Out of range(0-100)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            dbHelper.insertCourse(
                              courseName: nameController.text,
                              creditHours: creditHoursController.text,
                              percentage: percentageController.text,
                              grade: getGrade(percentageController.text),
                              semesterId: id,
                            );
                            setState(() {});
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
          future: course(),
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                    child: Text("No courses was added to $semesterName yet"));
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: total(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map>> totalSnapshot) {
                            if (totalSnapshot.hasData) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grade",
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
                                          "${totalSnapshot.data![0]["grade"]}",
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
                                        "GPA",
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
                                          "${totalSnapshot.data![0]["GPA"]}",
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
                                        "Total credit hours",
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
                                          "${totalSnapshot.data![0]["credit_hours"]}",
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
                                        const SizedBox(height: 8),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            nameController.text = snapshot
                                                .data![index]["course_name"];
                                            creditHoursController.text =
                                                snapshot.data![index]
                                                        ["credit_hours"]
                                                    .toString();
                                            percentageController.text = snapshot
                                                .data![index]["percentage"]
                                                .toString();
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Form(
                                                  key: formKey,
                                                  child: AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    title: const Text(
                                                        "Add New Course"),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextFormField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'Course Name',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Coutse Name must not be empty';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        TextFormField(
                                                          controller:
                                                              creditHoursController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'Credit Hours',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Credit Hours must not be empty';
                                                            } else if (int
                                                                    .tryParse(
                                                                        value) ==
                                                                null) {
                                                              return 'Credit Hours must be integer';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        TextFormField(
                                                          controller:
                                                              percentageController,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText:
                                                                'Percentage',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Percentage must not be empty';
                                                            } else if (double
                                                                    .tryParse(
                                                                        value) ==
                                                                null) {
                                                              return 'Percentage must be double';
                                                            } else if (double.parse(
                                                                        value) >
                                                                    100 ||
                                                                double.parse(
                                                                        value) <
                                                                    0) {
                                                              return 'Out of range(0-100)';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      FilledButton(
                                                        onPressed: () {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            dbHelper
                                                                .updateCourse(
                                                              courseName:
                                                                  nameController
                                                                      .text,
                                                              id: snapshot
                                                                      .data![
                                                                  index]["id"],
                                                              creditHour: int.parse(
                                                                  creditHoursController
                                                                      .text),
                                                              percentage:
                                                                  double.parse(
                                                                      percentageController
                                                                          .text),
                                                              grade: getGrade(
                                                                  percentageController
                                                                      .text),
                                                            );
                                                            setState(() {});
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                        child:
                                                            const Text("Done"),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          leading: const Icon(Icons.edit),
                                          title: Text(
                                              "Edit ${snapshot.data![index]["course_name"]}"),
                                        ),
                                        const SizedBox(height: 8),
                                        ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                    "Delete ${snapshot.data![index]["course_name"]}"),
                                                content: const Text(
                                                  "Are you sure you want to delete this course?\nYou will not be able to recover it again",
                                                  textAlign: TextAlign.center,
                                                ),
                                                actions: [
                                                  FilledButton(
                                                    onPressed: () {
                                                      dbHelper.deleteCourse(
                                                          snapshot.data![index]
                                                              ["id"]);
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
                                          title: Text(
                                              "Delete ${snapshot.data![index]["course_name"]}"),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA188C0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${snapshot.data![index]["course_name"]}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
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
                                            "${snapshot.data![index]["credit_hours"]}",
                                            style: const TextStyle(
                                                color: Colors.black),
                                          )),
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
                                                "${snapshot.data![index]["percentage"]}",
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              )),
                                            ),
                                          ],
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
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
