// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widget.dart';
import 'package:vacci_track_frontend/ui/date_picker.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:recase/recase.dart';

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

  late final Color themeColor = Helpers.getThemeColorWithUIColor(
      context: context, uiColor: widget.uiColor);

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
    await widget.assignAvatar(
      newgender: "",
      newprefix: "",
      newfirstName: "",
      newmiddleName: "",
      newlastName: "",
    );

    final API_URL = await Helpers.load_env();
    final endpoints = [
      "/api/get_prefix/",
      "/api/get_department_list/",
      "/api/get_designation_list/",
      "/api/get_facility_list/",
      "/api/get_vaccination_list/"
    ];

    final results = await Future.wait(endpoints
        .map((endpoint) => Helpers.makeGetRequest("http://$API_URL$endpoint")));

    if (mounted) {
      for (var result in results) {
        bool error = await Helpers.checkError(result[0], context);
        if (error) {
          return;
        }
      }
    }
    prefixlist = _mapToDropdown(results[0], 'gender');
    depatmentlist = _mapToDropdown(results[1], 'id', 'name');
    designationlist = _mapToDropdown(results[2], 'id', 'name');
    facilitylist = _mapToDropdown(results[3], 'id', 'name');
    vaccineList = results[4]
        .map<MultiSelectItem<dynamic>>(
            (item) => MultiSelectItem(item['id'], item['name']))
        .toList();

    if (mounted) {
      setState(() {
        _isSpinning = false;
      });
    }
  }

  List<DropdownMenuItem<String>> _mapToDropdown(List data, String valueKey,
      [String? childKey]) {
    return data.map((item) {
      return DropdownMenuItem<String>(
        value: item[valueKey].toString(),
        child: Text(childKey != null ? item[childKey] : item[valueKey]),
      );
    }).toList();
  }

  void submitHandler() async {
    if (_formKey.currentState!.validate() && mounted) {
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
      if (data.containsKey('error') && mounted) {
        setState(() {
          _isSpinning = false;
        });
        // ignore: use_build_context_synchronously
        HelpersWidget.showSnackBar(context, data['error']);
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
        HelpersWidget.showDialogOnScreen(
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
    if (mounted) {
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
    }

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
    double inputWidth = deviceWidth < 540
        ? deviceWidth
        : Helpers.minAndMax(deviceWidth * .8, 80, 175);

    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Card(
            borderOnForeground: true,
            elevation: 100,
            margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
            child: Container(
              color: themeColor,
              width: Helpers.minAndMax(deviceWidth * .8, 80, 800),
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  CustomSearchBar(
                    deviceWidth: deviceWidth,
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
                    controller: _searchController,
                    uiColor: widget.uiColor,
                    backgroundColor: themeColor,
                    hintText: widget.editPage
                        ? "Search PR or UHID In VacciTrack Database"
                        : "Search PR or UHID EHIS Database",
                    buttonText: widget.editPage ? 'Search' : 'Search in EHIS',
                    onChanged: (value) {
                      if (_searchError) {
                        setState(() {
                          _searchError = false;
                        });
                      }
                      _searchController.value = TextEditingValue(
                        text: value.toUpperCase(),
                        selection: _searchController.selection,
                      );
                    },
                  ),
                  _searchError
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Text(
                              "Enter a Valid UHID / PR Number",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 0, 0),
                                  fontSize: 12),
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
                              width: inputWidth,
                              hint: "Prefix",
                              items: prefixlist,
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              onSaved: (value) {
                                prefix = value!;
                              },
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              width: inputWidth,
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
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              width: inputWidth,
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
                            CustomDatePicker(
                              width: inputWidth,
                              dateTimeVal: joiningDate,
                              defaultLabel: "Joining Date",
                              onPressed: () async {
                                joiningDate = await Helpers.openDatePicker(
                                    context: context,
                                    helpText: "Select Joining Date");
                                if (joiningDate != null) {
                                  setState(() {});
                                }
                              },
                            ),
                            CustomInputField(
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              enabled: uhid != null ? false : true,
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              enabled: prNumber != null ? false : true,
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              width: inputWidth,
                              onSaved: (value) {
                                if (value == null) return;
                                emailID = value;
                              },
                              initialValue: emailID,
                              label: "Email ID",
                            ),
                            CustomDropDownField(
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              width: inputWidth,
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
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              value: designation,
                              onChanged: (v) {},
                              width: inputWidth,
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
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              value: facility,
                              onChanged: (v) {},
                              width: inputWidth,
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
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
                              initialValue: status,
                              width: inputWidth,
                              onSaved: (value) {
                                if (value == null) return;
                                status = value;
                              },
                              label: "Status",
                            ),
                            CustomDropDownField(
                              decoration: dropdownDecorationAddEmployee(
                                  color: widget.uiColor),
                              value: eligibility,
                              width: inputWidth,
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
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: MultiSelectDialogField(
                                  backgroundColor: themeColor,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: initialValueVaccine.isEmpty
                                              ? Colors.black
                                              : widget.uiColor,
                                          width: 2),
                                    ),
                                  ),
                                  cancelText: getCustomTextStyle(
                                      text: "Cancel",
                                      color: widget.uiColor,
                                      isBold: true,
                                      fontSize: 16),
                                  confirmText: getCustomTextStyle(
                                      text: "OK",
                                      color: widget.uiColor,
                                      isBold: true,
                                      fontSize: 16),
                                  searchTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  itemsTextStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  searchIcon: Icon(Icons.search,
                                      color: widget.uiColor, size: 43),
                                  closeSearchIcon: Icon(Icons.close,
                                      color: widget.uiColor, size: 43),
                                  items: vaccineList,
                                  checkColor: widget.uiColor,
                                  unselectedColor: Colors.white,
                                  dialogWidth: deviceWidth * .3,
                                  buttonIcon: const Icon(
                                    FontAwesomeIcons.syringe,
                                    color: Colors.black,
                                  ),
                                  buttonText: getCustomTextStyle(
                                      text: "Assign Vaccines",
                                      color: Colors.black,
                                      fontSize: 14,
                                      isBold: true),
                                  initialValue: initialValueVaccine,
                                  listType: MultiSelectListType.CHIP,
                                  selectedColor: widget.uiColor,
                                  selectedItemsTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  searchHint: 'Search Vaccine',
                                  searchHintStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  chipDisplay: MultiSelectChipDisplay(
                                      chipColor: widget.uiColor,
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
                                  title: CustomTextStyle(
                                      text: "Multi-Select Vaccines to Assign",
                                      color: widget.uiColor,
                                      isBold: true),
                                  searchable: true,
                                  separateSelectedItems: true,
                                  onConfirm: (value) {
                                    setState(() {
                                      initialValueVaccine = value;
                                    });
                                  }),
                            ),
                            CustomInputField(
                              lableIsBold: true,
                              labelFontSize: 14,
                              uiColor: widget.uiColor,
                              underlineBorder: true,
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
                              child: CustomTextStyle(
                                  text: "Reset",
                                  color: widget.uiColor,
                                  isBold: true),
                            ),
                            ElevatedButton(
                              onPressed: submitHandler,
                              child: CustomTextStyle(
                                  text: 'Submit',
                                  color: widget.uiColor,
                                  isBold: true),
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
          backgroundColor: themeColor,
          title: CustomTextStyle(
              text: 'Results Found With  "${_searchController.text}" ',
              color: widget.uiColor,
              isBold: true),
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
                    title: CustomTextStyle(
                      text:
                          '${user['prefix'] ?? ""} ${user['first_name'] ?? ""} ${user['middle_name'] ?? ""}  ${user['last_name'] ?? ""}',
                      color: widget.uiColor,
                      isBold: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextStyle(
                          text: 'UHID: ${user['uhid'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'PR Number: ${user['pr_number'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Gender: ${user['gender'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Phone Number: ${user['phone_number'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Email ID: ${user['email_id'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Facility: ${user['facility']?['name'] ?? ''}',
                          color: Colors.black,
                          isBold: true,
                        ),
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
        query: {"query": "param1=${_searchController.text}"});
    if ((empData[0] as Map).containsKey("error")) {
      // ignore: use_build_context_synchronously
      HelpersWidget.showSnackBar(context, empData[0]['error']);
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
        query: {"query": "param1=${_searchController.text}"});
    if (empData.isEmpty || (empData[0] as Map).containsKey("error")) {
      // ignore: use_build_context_synchronously
      HelpersWidget.showSnackBar(
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
    firstName = ReCase(empData["first_name"] ?? "").titleCase;
    middleName = ReCase(empData["middle_name"] ?? "").titleCase;
    lastName = ReCase(empData["last_name"] ?? "").titleCase;
    gender = empData["gender"];
    prNumber = empData["pr_number"];
    uhid = empData["uhid"];
    phoneNumber = empData["phone_number"];
    emailID = empData["email_id"]?.toString().toLowerCase();
    facility = empData["facility"]?["id"]?.toString();
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
    empData["designation"]?["id"].toString();

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
