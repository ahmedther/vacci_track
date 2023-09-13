import 'dart:js_interop';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class DepartmentAddForm extends StatefulWidget {
  DepartmentAddForm({required this.editPage, super.key});
  bool editPage;

  @override
  State<DepartmentAddForm> createState() => _DepartmentAddFormState();
}

class _DepartmentAddFormState extends State<DepartmentAddForm> {
  String? hod;
  String? departmentName;
  bool isSpinning = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchControllerHOD = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late List<DropdownMenuItem<String>>? hodList = null;
  int? _id = 0;

  @override
  void dispose() {
    _searchControllerHOD.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchHOD(BuildContext context) async {
    setState(() {
      isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List hodData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_hod/",
        query: "param1=${_searchControllerHOD.text}");
    if (hodData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, hodData[0]['error']);
      setState(() {
        isSpinning = false;
      });
      return;
    }

    hodList = await hodDropdownWorking(hodData);
    setState(() {
      isSpinning = false;
    });
  }

  Future<List<DropdownMenuItem<String>>> hodDropdownWorking(List data) async {
    return hodList = data.map((e) {
      return DropdownMenuItem<String>(
        value: e['id'].toString(),
        child: Text(
            "${e['prefix'] ?? ''} ${e['first_name'] ?? ''} ${e['middle_name'] ?? ''} ${e['last_name'] ?? ''}"),
      );
    }).toList();
  }

  void _searchDepartment(BuildContext context) async {
    setState(() {
      isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List departmentList = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_department/",
        query: "param1=${_searchController.text}");
    if (departmentList[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, departmentList[0]['error']);
      setState(() {
        isSpinning = false;
      });
      return;
    }

    if (departmentList.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, departmentList);
    } else {
      await updateForm(departmentList[0]);
    }
    setState(() {
      isSpinning = false;
    });
  }

  void submitHandler() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSpinning = true;
      });
      final API_URL = await Helpers.load_env();
      final Map data = await Helpers.makePostRequest(
          url: "http://$API_URL/api/add_department/",
          data: {
            if (widget.editPage) "id": _id,
            "name": departmentName,
            if (hod.isDefinedAndNotNull) "department_hod": hod,
            if (widget.editPage) "edit": widget.editPage,
          });
      if (data.containsKey('error')) {
        setState(() {
          isSpinning = false;
        });
        // ignore: use_build_context_synchronously
        Helpers.showSnackBar(context, data['error']);
        return;
      } else {
        // ignore: use_build_context_synchronously
        Helpers.showDialogOnScreen(
            context: context,
            btnMessage: 'OK',
            title: "✔ Successful",
            message: widget.editPage
                ? "Department Successfully Updated"
                : "Department Successfully Added",
            onPressed: () {});

        setState(() {
          // _formKey.currentState!.reset();

          _searchControllerHOD.clear();
          _searchController.clear();
          hodList = null;
          departmentName = null;
          isSpinning = false;
        });
      }
    }
  }

  Future updateForm(Map data) async {
    departmentName = data["name"];
    _id = data["id"];
    if (data["department_hod"] != null) {
      hod = data["department_hod"]["id"].toString();
      await hodDropdownWorking([data["department_hod"]]);
    }
  }

  Future resetBtnHandler() async {
    setState(() {
      hodList = null;
      departmentName = null;
      _formKey.currentState!.reset();
      _searchControllerHOD.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double inputWidth = Helpers.min_max(deviceWidth, .20, 500, 600);

    return isSpinning
        ? const SpinnerWithOverlay(
            spinnerColor: Colors.blue,
          )
        : Column(
            children: [
              if (widget.editPage) ...{
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                SizedBox(
                  width: inputWidth + 20,
                  child: SearchBar(
                    controller: _searchController,
                    elevation: const MaterialStatePropertyAll(2),
                    hintText: "Search For A Department ",
                    leading: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    trailing: Iterable.generate(
                      1,
                      (index) {
                        return OutlinedButton(
                          style: const ButtonStyle(
                            enableFeedback: true,
                            animationDuration: Duration(seconds: 2),
                          ),
                          child: Text(
                            deviceWidth < 900 ? '🔎' : 'Search',
                          ),
                          onPressed: () {
                            _searchDepartment(context);
                          },
                        );
                      },
                    ),
                    onChanged: (value) {},
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
              },
              Card(
                borderOnForeground: true,
                elevation: 100,
                margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  width: inputWidth + 20,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomInputField(
                          label: "Name",
                          initialValue: departmentName,
                          border: const OutlineInputBorder(),
                          width: inputWidth,
                          onSaved: (value) {
                            if (value == null) return;
                            departmentName = value;
                          },
                          onChanged: (value) {
                            departmentName = value;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 3) {
                              return "Department name can not be empty or less then 3 characters!";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        SearchBar(
                          controller: _searchControllerHOD,
                          elevation: const MaterialStatePropertyAll(2),
                          hintText: "Enter PR No Or Name",
                          leading: FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          trailing: Iterable.generate(
                            1,
                            (index) {
                              return OutlinedButton(
                                style: const ButtonStyle(
                                  enableFeedback: true,
                                  animationDuration: Duration(seconds: 2),
                                ),
                                child: Text(
                                  deviceWidth < 900
                                      ? '🔎'
                                      : 'Search in Employees',
                                ),
                                onPressed: () {
                                  hod = null;
                                  _searchHOD(context);
                                },
                              );
                            },
                          ),
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 40),
                        CustomDropDownField(
                          decoration: const InputDecoration(
                            labelText: 'Head of Department',
                            border: OutlineInputBorder(),
                          ),
                          value: hod,
                          items: hodList ?? [],
                          width: inputWidth,
                          hint: "Head Of Department",
                          onChanged: (value) {
                            hod = value;
                          },
                        ),
                        SizedBox(
                          height: deviceHeight * 0.02,
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 40,
                          children: [
                            TextButton(
                              onPressed: resetBtnHandler,
                              child: const Text('Reset'),
                            ),
                            ElevatedButton(
                              onPressed: submitHandler,
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Future<void> _dialogBuilder(BuildContext context, List departmentData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Multiple Departments Found with the keyword ${_searchController.text}"),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: departmentData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> department = departmentData[index];
                return Card(
                  child: ListTile(
                    hoverColor: const Color.fromARGB(31, 0, 0, 0),
                    onTap: () async {
                      await updateForm(department);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Helpers.getRandomColor(),
                      child: const FaIcon(
                        FontAwesomeIcons.buildingUser,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      department["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (department["department_hod"] != null) ...{
                            Text(
                                "HOD : ${department["department_hod"]["prefix"] ?? ''}"
                                " ${department["department_hod"]["first_name"] ?? ''}"
                                " ${department["department_hod"]["middle_name"] ?? ''}"
                                " ${department["department_hod"]["last_name"] ?? ''}"),
                          } else ...{
                            const Text("No HOD is Assigned."),
                          }
                        ]),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}