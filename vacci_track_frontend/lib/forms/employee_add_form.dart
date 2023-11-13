import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';

class EmployeeAddForm extends StatefulWidget {
  final Function assignAvatar;
  final bool editPage;
  final Color uiColor;

  const EmployeeAddForm({
    super.key,
    required this.assignAvatar,
    required this.editPage,
    required this.uiColor,
  });

  @override
  State<EmployeeAddForm> createState() => _EmployeeAddFormState();
}

class _EmployeeAddFormState extends State<EmployeeAddForm> {
  final TextEditingController _searchController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isSpinning = true;

  bool _searchError = false;

  bool _useUpdateOthers = false;

  late final List<DropdownMenuItem<String>> prefixlist;
  late final List<DropdownMenuItem<String>> depatmentlist;
  late final List<DropdownMenuItem<String>> designationlist;
  late final List<DropdownMenuItem<String>> facilitylist;
  late final List<MultiSelectItem<dynamic>> vaccineList;

  String? prefix;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;
  DateTime? joiningDate;
  String? prNumber;
  String? uhid;
  String? phoneNumber;
  String? emailID;
  String? department;
  String? designation;
  String? facility;
  String? status;
  String? eligibility;
  String? notes;

  List initialValueVaccine = [];

  late final Color chipColor = Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      allFuture();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future allFuture() async {
    final API_URL = await Helpers.load_env();

    final List prefixData =
        await Helpers.makeGetRequest("http://$API_URL/api/get_prefix/");
    prefixlist = prefixData.map((item) {
      return DropdownMenuItem<String>(
        value: item['gender'].toString(),
        child: Text(item['gender']),
      );
    }).toList();

    final List deptData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_department_list/");
    depatmentlist = deptData.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'].toString(),
        child: Text(item['name']),
      );
    }).toList();

    final List desigData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_designation_list/");
    designationlist = desigData.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'].toString(),
        child: Text(item['name']),
      );
    }).toList();

    final List facilityData =
        await Helpers.makeGetRequest("http://$API_URL/api/get_facility_list/");
    facilitylist = facilityData.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'].toString(),
        child: Text(item['name']),
      );
    }).toList();

    final List vaccineData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccination_list/");
    vaccineList = vaccineData.map((item) {
      return MultiSelectItem(item['id'], item['name']);
    }).toList();

    setState(() {
      _isSpinning = false;
    });
  }

  void submitHandler() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSpinning = true;
      });
      final API_URL = await Helpers.load_env();
      final Map data = await Helpers.makePostRequest(
          url: "http://$API_URL/api/create_new_employee/",
          data: {
            "prefix": prefix,
            "first_name": firstName,
            "middle_name": middleName,
            "last_name": lastName,
            "gender": gender,
            "joining_date": joiningDate.toString(),
            "pr_number": prNumber,
            "uhid": uhid,
            "phone_number": phoneNumber,
            "email_id": emailID,
            "department": department,
            "designation": designation,
            "facility": facility,
            "status": status,
            "eligibility": eligibility,
            "notes_remarks": notes,
            "vaccinations": initialValueVaccine,
            if (widget.editPage) "edit": widget.editPage,
          });
      if (data.containsKey('error')) {
        setState(() {
          _isSpinning = false;
        });
        // ignore: use_build_context_synchronously
        Helpers.showSnackBar(context, data['error']);
      } else {
        prefix = null;
        firstName = "";
        middleName = "";
        lastName = "";
        gender = null;
        phoneNumber = "";
        emailID = "";
        prNumber = null;
        uhid = null;
        joiningDate = null;
        _searchController.clear();
        await widget.assignAvatar(
          newgender: "",
          newprefix: "",
          newfirstName: "",
          newmiddleName: "",
          newlastName: "",
        );
        // ignore: use_build_context_synchronously
        Helpers.showDialogOnScreen(
          context: context,
          btnMessage: 'OK',
          title: "✔ Successful",
          message: widget.editPage
              ? "User Successfully Updated"
              : "User Successfully Added",
          onPressed: () {},
        );
        await resetBtnHandler();
      }
    }
  }

  Future resetBtnHandler() async {
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
      _searchController.clear();
      prefix = null;
      status = '';
      notes = '';
      firstName = "";
      middleName = "";
      lastName = "";
      gender = null;
      phoneNumber = "";
      emailID = "";
      prNumber = null;
      uhid = null;
      joiningDate = null;
      department = null;
      designation = null;
      facility = null;
      eligibility = null;
      initialValueVaccine = [];
      _searchError = false;
      _isSpinning = false;
    });

    await widget.assignAvatar(
      newgender: "",
      newprefix: "",
      newfirstName: "",
      newmiddleName: "",
      newlastName: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Card(
            borderOnForeground: true,
            elevation: 100,
            margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
            child: Container(
              padding: const EdgeInsets.all(30),
              width: deviceWidth * 0.70,
              child: Column(
                children: [
                  SearchBar(
                    controller: _searchController,
                    elevation: const MaterialStatePropertyAll(2),
                    hintText: widget.editPage
                        ? "Search PR or UHID In VacciTrack Database"
                        : "Search PR or UHID EHIS Database",
                    leading: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: chipColor,
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
                            widget.editPage
                                ? deviceWidth < 900
                                    ? '🔎'
                                    : 'Search'
                                : deviceWidth < 900
                                    ? '🔎'
                                    : 'Search in EHIS',
                          ),
                          onPressed: () {
                            if (_searchController.text.trim().length > 3) {
                              widget.editPage
                                  ? searchDjango(context)
                                  : searchEhisOracle(context);
                            } else {
                              setState(() {
                                _searchError = true;
                              });
                            }
                          },
                        );
                      },
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchError = false;
                      });
                      _searchController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: _searchController.selection,
                      );
                    },
                  ),
                  _searchError
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Text(
                              "Enter a Valid UHID / PR Number",
                              style: TextStyle(
                                  color: Colors.red.shade800, fontSize: 12),
                            ),
                          ),
                        )
                      : const SizedBox(width: 0, height: 17),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 10,
                          children: [
                            CustomDropDownField(
                              value: prefix,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Prefix",
                              onSaved: (value) {
                                prefix = value!;
                              },
                              items: prefixlist,
                              onChanged: (value) async {
                                await widget.assignAvatar(newprefix: value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Prefix Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              initialValue: firstName,
                              onChanged: (value) {
                                widget.assignAvatar(newfirstName: value);
                              },
                              onSaved: (value) {
                                if (value == null) return;
                                firstName = value;
                              },
                              label: "First Name",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "First Name Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              onChanged: (value) async {
                                await widget.assignAvatar(newmiddleName: value);
                              },
                              initialValue: middleName,
                              onSaved: (value) {
                                if (value == null) return;
                                middleName = value;
                              },
                              label: "Middle Name",
                            ),
                            CustomInputField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              onChanged: (value) async {
                                await widget.assignAvatar(newlastName: value);
                              },
                              onSaved: (value) {
                                if (value == null) return;
                                lastName = value;
                              },
                              initialValue: lastName,
                              label: "Last Name",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "Last Name Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomDropDownField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Gender",
                              onSaved: (value) {
                                gender = value!;
                              },
                              value: gender,
                              items: const [
                                DropdownMenuItem(
                                    value: "Male", child: Text("Male")),
                                DropdownMenuItem(
                                    value: "Female", child: Text("Female")),
                              ],
                              onChanged: (value) async {
                                if (value == 'Female') {
                                  await widget.assignAvatar(
                                      newgender: 'female');
                                }
                                if (value == 'Male') {
                                  await widget.assignAvatar(newgender: 'male');
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Gender Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            Container(
                              alignment: Alignment.center,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    joiningDate != null
                                        ? formater.format(joiningDate!)
                                        : "Joining Date",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      joiningDate =
                                          await Helpers.openDatePicker(context);
                                      if (joiningDate != null) {
                                        setState(() {});
                                      }
                                    },
                                    icon: const FaIcon(
                                        FontAwesomeIcons.calendarDays),
                                  ),
                                ],
                              ),
                            ),
                            CustomInputField(
                              enabled: uhid != null ? false : true,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              onSaved: (value) {
                                if (value == null) return;
                                uhid = value;
                              },
                              initialValue: uhid,
                              label: "UHID",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "UHID Number  Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              enabled: prNumber != null ? false : true,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              onSaved: (value) {
                                if (value == null) return;
                                prNumber = value;
                              },
                              initialValue: prNumber,
                              label: "PR Number",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "PR Number  Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              onSaved: (value) {
                                if (value == null) return;
                                phoneNumber = value;
                              },
                              initialValue: phoneNumber,
                              label: "Phone Number",
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "Phone Number  Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              onSaved: (value) {
                                if (value == null) return;
                                emailID = value;
                              },
                              initialValue: emailID,
                              label: "Email ID",
                            ),
                            CustomDropDownField(
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Department",
                              onChanged: (v) {},
                              onSaved: (value) {
                                department = value!;
                              },
                              items: depatmentlist,
                              value: department,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Department Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomDropDownField(
                              value: designation,
                              onChanged: (v) {},
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Designation",
                              onSaved: (value) {
                                designation = value!;
                              },
                              items: designationlist,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Designation Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomDropDownField(
                              value: facility,
                              onChanged: (v) {},
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Facility",
                              onSaved: (value) {
                                facility = value!;
                              },
                              items: facilitylist,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Facility Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              initialValue: status,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              onSaved: (value) {
                                if (value == null) return;
                                status = value;
                              },
                              label: "Status",
                            ),
                            CustomDropDownField(
                              value: eligibility,
                              width:
                                  Helpers.min_max(deviceWidth, .12, 163, 300),
                              hint: "Eligibilty",
                              onSaved: (value) {
                                eligibility = value!;
                              },
                              onChanged: (value) {},
                              items: const [
                                DropdownMenuItem(
                                    value: "Eligible", child: Text("Eligible")),
                                DropdownMenuItem(
                                    value: "Non - Eligible",
                                    child: Text("Non - Eligible")),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Gender Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            MultiSelectDialogField(
                                items: vaccineList,
                                checkColor: Colors.white,
                                unselectedColor: Colors.white,
                                dialogWidth: deviceWidth * .3,
                                buttonIcon:
                                    const Icon(FontAwesomeIcons.syringe),
                                buttonText: const Text("Assign Vaccines",
                                    style: TextStyle(fontSize: 16)),
                                initialValue: initialValueVaccine,
                                listType: MultiSelectListType.CHIP,
                                selectedColor: chipColor,
                                selectedItemsTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                searchHint: 'Search Vaccine',
                                chipDisplay: MultiSelectChipDisplay(
                                    chipColor: chipColor,
                                    scroll: true,
                                    textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    onTap: (chip) {
                                      setState(() {
                                        if (initialValueVaccine.length > 1) {
                                          initialValueVaccine.remove(chip);
                                        } else {
                                          initialValueVaccine = [];
                                        }
                                      });
                                    }),
                                title: const Text(
                                    "Multi-Select Vaccine to Assign"),
                                searchable: true,
                                separateSelectedItems: true,
                                onConfirm: (value) {
                                  initialValueVaccine = value;
                                }),
                            CustomInputField(
                              initialValue: notes,
                              width: deviceWidth,
                              onSaved: (value) {
                                if (value == null) return;
                                notes = value;
                              },
                              label: "Notes",
                              maxLines: 3,
                            ),
                          ],
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
                ],
              ),
            ),
          );
  }

  Future<void> _dialogBuilder(BuildContext context, List empData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Results Found With ${_searchController.text} '),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width * .3,
            child: ListView.builder(
              itemCount: empData.length,
              itemBuilder: (context, index) {
                Map user = empData[index];
                return Card(
                  child: ListTile(
                    hoverColor: const Color.fromARGB(31, 0, 0, 0),
                    onTap: () async {
                      _useUpdateOthers ? await updateOtherDeatils(user) : null;
                      await updateEmpForm(user);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Helpers.getRandomColor(),
                      child: user['first_name'] != null
                          ? Text(user['first_name'][0],
                              style: const TextStyle(color: Colors.white))
                          : const FaIcon(FontAwesomeIcons.userAlt,
                              color: Colors.white),
                    ),
                    title: Text(
                        '${user['prefix'] ?? ""} ${user['first_name'] ?? ""} ${user['middle_name'] ?? ""}  ${user['last_name'] ?? ""}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('UHID: ${user['uhid'] ?? ''}'),
                        Text('PR Number: ${user['pr_number'] ?? ''}'),
                        Text('Gender: ${user['gender'] ?? ''}'),
                        Text('Phone Number: ${user['phone_number'] ?? ''}'),
                        Text('Email ID: ${user['email_id'] ?? ''}'),
                        Text('Facility: ${user['facility']['name'] ?? ''}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
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

  void searchEhisOracle(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/searh_emp_on_oracle_db/",
        query: "param1=${_searchController.text}");
    if ((empData[0] as Map).containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, empData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }
    if (empData.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, empData);
    } else {
      // ignore: use_build_context_synchronously
      await updateEmpForm(empData[0]);
    }
    setState(() {
      _isSpinning = false;
    });
  }

  void searchDjango(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_employee/",
        query: "param1=${_searchController.text}");
    if (empData.isEmpty || (empData[0] as Map).containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(
          context,
          empData.isEmpty
              ? "No Results Found with UHID/PR Number ${_searchController.text}"
              : (empData[0] as Map).containsKey("error")
                  ? empData[0]["error"]
                  : "No Results Found with UHID/PR Number ${_searchController.text}");
      setState(() {
        _isSpinning = false;
      });
      return;
    }
    if (empData.length > 1) {
      // ignore: use_build_context_synchronously
      _useUpdateOthers = true;
      await _dialogBuilder(context, empData);
      _useUpdateOthers = false;
    } else {
      // ignore: use_build_context_synchronously
      await updateOtherDeatils(empData[0]);
      await updateEmpForm(empData[0]);
    }

    setState(() {
      _isSpinning = false;
    });
  }

  Future updateEmpForm(Map empData) async {
    prefix = empData["prefix"] ?? "Mr.";
    firstName = empData["first_name"];
    middleName = empData["middle_name"];
    lastName = empData["last_name"];
    gender = empData["gender"];
    prNumber = empData["pr_number"];
    uhid = empData["uhid"];
    phoneNumber = empData["phone_number"];
    emailID = empData["email_id"];
    facility = empData["facility"]["id"]?.toString();
    await widget.assignAvatar(
      newgender: gender ?? "",
      newprefix: prefix ?? "",
      newfirstName: firstName ?? "",
      newmiddleName: middleName ?? "",
      newlastName: lastName ?? "",
    );
  }

  Future updateOtherDeatils(Map empData) async {
    if (empData["joining_date"] != null) {
      joiningDate = DateTime.parse(empData["joining_date"]);
    }
    prNumber = empData["pr_number"];
    uhid = empData["uhid"];
    phoneNumber = empData["phone_number"];
    department =
        empData["department"] != null && empData["department"]["id"] != null
            ? empData["department"]["id"].toString()
            : null;

    designation =
        empData["designation"] != null && empData["designation"]["id"] != null
            ? empData["designation"]["id"].toString()
            : null;
    empData["designation"]["id"].toString();

    status = empData["status"];
    eligibility = empData["eligibility"];
    notes = empData["notes_remarks"];

    initialValueVaccine.addAll(
      (empData["vaccinations"] as List?)
              ?.map<int?>((value) => value?['id'])
              .where((id) => id != null)
              .cast<int>() // Cast the filtered values to int
              .toList() ??
          [],
    );
  }
}
