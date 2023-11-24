import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/components/record_vac_form_profile.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

import '../ui/spinner.dart';

class RecordVaccineForm extends StatefulWidget {
  const RecordVaccineForm(
      {required this.editPage,
      required this.assignAvatar,
      required this.resetAvatar,
      required this.uiColor,
      super.key});

  final Function assignAvatar;
  final Function resetAvatar;
  final Color uiColor;
  final bool editPage;

  @override
  State<RecordVaccineForm> createState() => _RecordVaccineFormState();
}

class _RecordVaccineFormState extends State<RecordVaccineForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isSpinning = false;
  bool _isForm = false;

  String? prefix;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;
  String? prNumber;
  String? uhid;
  String? department;
  String? designation;
  List? empData1;
  bool textSelectionCount = false;

  String? vaccine;
  String? dose;

  String? doseAdministeredBy;
  String? doseAdministeredPrNum;
  DateTime? doseDueDate;

  late List<DropdownMenuItem<String>>? vaccineList;
  late List<DropdownMenuItem<String>>? doseList;

  late List doseData;

  late Color themeContainerColor;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.resetAvatar();
    });
  }

  Future updateEmpForm(Map empData) async {
    setState(() {
      _isSpinning = true;
    });

    prefix = empData["prefix"] ?? "Mr.";
    firstName = empData["first_name"];
    middleName = empData["middle_name"];
    lastName = empData["last_name"];
    gender = empData["gender"];
    prNumber = empData["pr_number"] ?? "NO PR Number Entered";
    uhid = empData["uhid"] ?? "NO UHID Entered";
    department =
        empData["department"] != null && empData["department"]["id"] != null
            ? empData["department"]["name"].toString()
            : null;

    designation =
        empData["designation"] != null && empData["designation"]["id"] != null
            ? empData["designation"]["name"].toString()
            : null;
    // phoneNumber = empData["phone_number"];
    // emailID = empData["email_id"];
    // facility = empData["facility"]["id"]?.toString();
    vaccineList = generateDropDownList(empData["vaccinations"] ?? []);

    await widget.assignAvatar(
      newgender: gender ?? "",
      newprefix: prefix ?? "",
      newfirstName: firstName ?? "",
      newmiddleName: middleName ?? "",
      newlastName: lastName ?? "",
    );
    setState(() {
      _isSpinning = false;
    });
  }

  Future searchEmployee(BuildContext context, String query,
      {bool spinning = false}) async {
    if (spinning) {
      setState(() {
        _isSpinning = true;
      });
    }
    // ignore: non_constant_identifier_names
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_employee_by_name/",
        query: "param1=$query");
    if (spinning &&
        (empData.isEmpty || (empData[0] as Map).containsKey("error"))) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(
          context,
          empData.isEmpty
              ? "No Results Found with UHID/PR Number $query"
              : (empData[0] as Map).containsKey("error")
                  ? empData[0]["error"]
                  : "No Results Found with UHID/PR Number $query");
      if (spinning) {
        setState(() {
          _isSpinning = false;
        });
      }

      return;
    }
    empData1 = empData;
    if (spinning) {
      _isForm = true;
      // await updateOtherDeatils(empData[0]);
      await updateEmpForm(empData[0]);
      setState(() {
        _isSpinning = false;
      });
    }
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
            if (widget.editPage) "edit": widget.editPage,
          });
      if (data.containsKey('error')) {
        setState(() {
          _isSpinning = false;
        });
        // ignore: use_build_context_synchronously
        Helpers.showSnackBar(context, data['error']);
      } else {
        // ignore: use_build_context_synchronously
        Helpers.showDialogOnScreen(
          context: context,
          btnMessage: 'OK',
          title: "✔ Successful",
          message: widget.editPage
              ? "Dose Administered Updated"
              : "Dose Successfully Administered",
          onPressed: () {},
        );
        await resetBtnHandler();
      }
    }
  }

  Future resetBtnHandler({bool? useSoftReset = false}) async {
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
      prefix = null;
      firstName = "";
      middleName = "";
      lastName = "";
      gender = null;
      _isForm = false;

      vaccineList = null;
      vaccine = null;

      if (useSoftReset ?? false) softFormReset();

      _isSpinning = false;
    });

    // ignore: use_build_context_synchronously
    await widget.assignAvatar(
      newgender: "",
      newprefix: "",
      newfirstName: "",
      newmiddleName: "",
      newlastName: "",
    );
  }

  List<DropdownMenuItem<String>> generateDropDownList(List data,
      {String? value = "id", String label = "name"}) {
    return data.map((e) {
      return DropdownMenuItem<String>(
        value: e[value].toString(),
        child: Text(e[label]),
      );
    }).toList();
  }

  Future<void> _searchDose(BuildContext context, value) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    doseData = await Helpers.makeGetRequest("http://$API_URL/api/search_dose/",
        query: "param1=$value");

    if (doseData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, doseData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    doseList = generateDropDownList(doseData);
    setState(() {
      _isSpinning = false;
    });
  }

  void calculateDueDate(String value) {
    final int gap = doseData.firstWhere(
        (dose) => dose['id'] == int.parse(value))["gap_before_next_dose"];
    DateTime now = DateTime.now();
    doseDueDate = DateTime(now.year, now.month + gap, now.day);
  }

  void softFormReset() {
    doseDueDate = null;
    doseList = null;

    dose = null;
    doseDueDate = null;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    late final Color profileColor =
        Helpers.getUIandBackgroundColor(gender ?? "male")[0];
    themeContainerColor = Helpers.getThemeColorWithUIColor(
        context: context, uiColor: widget.uiColor);

    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Column(
            children: [
              if (_isForm && deviceWidth > 900)
                RecordVaccineEmployeeProfile(
                    profileColor: profileColor,
                    gender: gender ?? "Not Found",
                    prNumber: prNumber ?? "Not Found",
                    uhid: uhid ?? "Not Found"),
              Card(
                borderOnForeground: true,
                elevation: 100,
                margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
                child: Container(
                  color: themeContainerColor,
                  padding: const EdgeInsets.all(30),
                  width: deviceWidth * 0.70,
                  child: Column(
                    children: [
                      SearchAnchor(
                        viewBackgroundColor: themeContainerColor,
                        builder: (BuildContext _context,
                            SearchController controller) {
                          return CustomSearchBar(
                            deviceWidth: deviceWidth,
                            onPressed: () async {
                              await searchEmployee(context, controller.text,
                                  spinning: true);
                            },
                            controller: controller,
                            uiColor: widget.uiColor,
                            backgroundColor: themeContainerColor,
                            hintText:
                                "Search For Employees With Name or UHID/PR Number",
                            onTap: () async {
                              final query = controller.text.length > 3
                                  ? controller.text
                                  : "";
                              await searchEmployee(context, query);
                              controller.openView();
                            },
                          );
                        },
                        viewElevation: 100,
                        suggestionsBuilder: (BuildContext context,
                            SearchController controller) async {
                          Future.delayed(Duration.zero, () {
                            controller.selection = TextSelection.collapsed(
                                offset: controller.text.length);
                          });
                          await searchEmployee(context, controller.text);
                          if (empData1 == null || empData1!.isEmpty) return [];
                          return empData1!.map(
                            (item) {
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  hoverColor: const Color.fromARGB(31, 0, 0, 0),
                                  onTap: () async {
                                    await resetBtnHandler(useSoftReset: true);
                                    await updateEmpForm(item);
                                    setState(() {
                                      _isForm = true;
                                    });

                                    controller.closeView(controller.text);
                                    // _useUpdateOthers
                                    //     ? await updateOtherDeatils(user)
                                    //     : null;
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Helpers.getRandomColor(),
                                    child: item['first_name'] != null
                                        ? CustomTextStyle(
                                            text: item['first_name'][0],
                                            isBold: true,
                                            color: Colors.white)
                                        : const FaIcon(FontAwesomeIcons.userAlt,
                                            color: Colors.white),
                                  ),
                                  title: CustomTextStyle(
                                      text:
                                          '${item['prefix'] ?? ""} ${item['first_name'] ?? ""} ${item['middle_name'] ?? ""}  ${item['last_name'] ?? ""}',
                                      isBold: true,
                                      color: widget.uiColor),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTextStyle(
                                          text: 'UHID: ${item['uhid'] ?? ''}',
                                          isBold: true,
                                          color: Colors.black),
                                      CustomTextStyle(
                                          text:
                                              'PR Number: ${item['pr_number'] ?? ''}',
                                          isBold: true,
                                          color: Colors.black),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        viewBuilder: (Iterable<Widget> suggestions) {
                          return ListView.builder(
                              itemCount: suggestions.length,
                              itemBuilder: ((context, index) {
                                return suggestions.elementAt(index);
                              }));
                        },
                      ),
                      if (!_isForm) ...{
                        const SizedBox(height: 50),
                        FaIcon(
                          FontAwesomeIcons.handPointUp,
                          color: widget.uiColor,
                          size: 50,
                        ).animate().fadeIn().shake().shimmer(),
                        const SizedBox(height: 40),
                        CustomTextStyle(
                          text: "Please Search For An Employee To Continue",
                          color: widget.uiColor,
                          fontSize: 32,
                          isBold: true,
                        ).animate().fadeIn().shake().shimmer(),
                      },
                      if (_isForm) ...{
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: [
                                  CustomDropDownField(
                                    value: vaccine,
                                    width: Helpers.min_max(
                                        deviceWidth, .12, 163, 300),
                                    hint: "Assigned Vaccines",
                                    items: vaccineList,
                                    decoration: dropdownDecorationAddEmployee(
                                        color: widget.uiColor),
                                    onSaved: (value) {
                                      vaccine = value!;
                                    },
                                    onChanged: (value) async {
                                      softFormReset();

                                      vaccine = value!;

                                      _searchDose(context, value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Vaccine Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomDropDownField(
                                    value: dose,
                                    width: Helpers.min_max(
                                        deviceWidth, .12, 163, 300),
                                    hint: "Select Dose",
                                    items: doseList,
                                    disabledHint: const Text("Select Dose"),
                                    decoration: dropdownDecorationAddEmployee(
                                        color: widget.uiColor,
                                        isDisabled:
                                            doseList == null ? true : false),
                                    onSaved: (value) {
                                      dose = value!;
                                    },
                                    onChanged: (value) {
                                      calculateDueDate(value!);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Dose Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputField(
                                    enabled: doseList == null ? false : true,
                                    lableIsBold: true,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    underlineBorder: true,
                                    width: Helpers.min_max(
                                        deviceWidth, .12, 163, 300),
                                    initialValue: doseAdministeredBy,
                                    onSaved: (value) {
                                      if (value == null) return;
                                      doseAdministeredBy = value;
                                    },
                                    label: "Dose Administered By Name",
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim().isEmpty) {
                                        return "Dose Administered By Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputField(
                                    enabled: doseList == null ? false : true,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    underlineBorder: true,
                                    width: Helpers.min_max(
                                        deviceWidth, .12, 163, 300),
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // Only allow digits
                                    ],
                                    onSaved: (value) {
                                      if (value == null) return;
                                      doseAdministeredPrNum = value;
                                    },
                                    initialValue: doseAdministeredPrNum,
                                    label: "Dose Administered PR",
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim().isEmpty) {
                                        return "Dose Administered PR Number Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomInputField(
                                    enabled: false,
                                    lableIsBold: true,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    underlineBorder: true,
                                    width: Helpers.min_max(
                                        deviceWidth, .12, 163, 300),
                                    // initialValue: doseDueDate != null
                                    //     ? formater.format(doseDueDate!)
                                    //     : null,
                                    initialValue: doseDueDate.toString(),
                                    label: "Next Dose Due Date",
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
                      }
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
