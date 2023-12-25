import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/date_picker.dart';
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

  late int? empId;
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
  String? notes;

  String? vaccine;
  String? dose;

  String? doseAdministeredBy;
  String? doseAdministeredPrNum;
  DateTime? doseAdministeredDate;
  String? nextDoseDueDate;
  DateTime? doseDueDate;
  String? isDoseDueText;
  bool? isDoseDue;

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

    empId = empData["id"];
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
        query: {"query": "param1=$query"});
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
          url: "http://$API_URL/api/add_vaccination_data/",
          data: {
            "employee_id": empId,
            "vaccination_id": vaccine,
            "dose_id": dose,
            "dose_administered_by_name": doseAdministeredBy,
            "dose_administered_by_pr_number": doseAdministeredPrNum,
            "dose_date": doseAdministeredDate.toString(),
            "next_dose_due_date":
                nextDoseDueDate == "Last Dose" ? null : nextDoseDueDate,
            "is_dose_due": false,
            "is_completed": nextDoseDueDate == "Last Dose" ? true : false,
            "notes_remarks": notes,
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
          message: "Vaccination Administered",
          onPressed: () {},
        );
        await resetBtnHandler(useSoftReset: true);
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
        query: {"query": "$empId=$value"});

    if (doseData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, doseData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }
    isDoseDue = doseData[0]["is_dose_due"];

    doseDueDate = doseData[0]["dose_due_date"] != null
        ? DateTime.parse(doseData[0]["dose_due_date"])
        : null;

    doseList = generateDropDownList(doseData);
    setState(() {
      _isSpinning = false;
    });
  }

  Future<void> calculateDueDate(String value) async {
    setState(() {
      _isSpinning = true;
    });
    final int gap = doseData.firstWhere(
        (dose) => dose['id'] == int.parse(value))["gap_before_next_dose"];
    doseAdministeredDate = DateTime.now();
    nextDoseDueDate = gap > 0
        ? formater.format(DateTime(doseAdministeredDate!.year,
            doseAdministeredDate!.month + gap, doseAdministeredDate!.day))
        : "Last Dose";
    isDoseDueText = doseDueDate != null
        ? (isDoseDue == true
            ? "Yes! This Dose Is Due As of \n${formater.format(doseDueDate!)}."
            : "No! This Dose is not Due Before \n${formater.format(doseDueDate!)}. \nPlease note that you are administering this dose before its due date!")
        : "Dose due date is not available.";

    await Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        _isSpinning = false;
      });
    });
  }

  void softFormReset() {
    nextDoseDueDate = null;
    doseList = null;
    dose = null;
    doseDueDate = null;
    isDoseDueText = null;
    doseAdministeredBy = null;
    doseAdministeredPrNum = null;
    doseAdministeredDate = null;
    isDoseDue = false;
    notes = null;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    double inputWidth = Helpers.minAndMax(deviceWidth * .8, 200, 600);
    late final Color profileColor =
        Helpers.getUIandBackgroundColor(gender ?? "male")[0];
    themeContainerColor = Helpers.getThemeColorWithUIColor(
        context: context, uiColor: widget.uiColor);
    if (widget.editPage) _isForm = false;

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
                  width: inputWidth + 30,
                  child: Column(
                    children: [
                      if (!widget.editPage) ...{
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
                            if (empData1 == null || empData1!.isEmpty)
                              return [];
                            return empData1!.map(
                              (item) {
                                return Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    hoverColor:
                                        const Color.fromARGB(31, 0, 0, 0),
                                    onTap: () async {
                                      setState(() {
                                        _isSpinning = true;
                                      });
                                      Future.delayed(
                                          const Duration(milliseconds: 10),
                                          () async {
                                        await resetBtnHandler(
                                            useSoftReset: true);
                                        await updateEmpForm(item);
                                        setState(() {
                                          _isForm = true;
                                        });
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
                                          : const FaIcon(
                                              FontAwesomeIcons.userAlt,
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
                      },
                      if (!_isForm) ...{
                        const SizedBox(height: 50),
                        FaIcon(
                          widget.editPage
                              ? FontAwesomeIcons.solidCircleXmark
                              : FontAwesomeIcons.handPointUp,
                          color: widget.editPage
                              ? const Color.fromARGB(255, 255, 17, 0)
                              : widget.uiColor,
                          size: 50,
                        ).animate().fadeIn().shake().shimmer(),
                        const SizedBox(height: 40),
                        CustomTextStyle(
                          text: widget.editPage
                              ? """Please note that once a Dose record has been administered, it cannot be modified. 
                              
If you believe that a mistake has been made contact the I.T Department for assistance. 
                              
They can be reached at extension 33333."""
                              : "Please Search For An Employee To Continue...",
                          textAlign: TextAlign.center,
                          color: widget.editPage
                              ? const Color.fromARGB(255, 255, 17, 0)
                              : widget.uiColor,
                          fontSize: widget.editPage ? 20 : 32,
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
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: inputWidth,
                                  ),
                                  CustomDropDownField(
                                    value: vaccine,
                                    width: inputWidth,
                                    hint: "Select From Assigned Vaccines",
                                    items: vaccineList,
                                    decoration: dropdownDecoration(
                                        label: "Vaccination",
                                        color: widget.uiColor,
                                        isDisabled: vaccineList!.isEmpty),
                                    disabledHint: const Text(
                                        "No Vaccination Has Been Assigned"),
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
                                  SizedBox(
                                    height: 20,
                                    width: inputWidth,
                                  ),
                                  CustomDropDownField(
                                    value: dose,
                                    width: inputWidth,
                                    hint: "Select Dose",
                                    items: doseList,
                                    decoration: dropdownDecoration(
                                        label: "Dose",
                                        color: widget.uiColor,
                                        isDisabled:
                                            doseList == null ? true : false),
                                    disabledHint: const Text("Select Dose"),
                                    onSaved: (value) {
                                      dose = value!;
                                    },
                                    onChanged: (value) async {
                                      dose = value!;
                                      await calculateDueDate(value);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Dose Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    child: CustomTextStyle(
                                      text: "Dose Administered By Name",
                                      isBold: true,
                                      color:
                                          doseList == null ? Colors.grey : null,
                                    ),
                                  ),
                                  CustomInputField(
                                    enabled: doseList == null ? false : true,
                                    lableIsBold: true,
                                    underlineBorder: true,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    initialValue: doseAdministeredBy,
                                    onSaved: (value) {
                                      if (value == null) return;
                                      doseAdministeredBy = value;
                                    },
                                    label: "",
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim().length < 3) {
                                        return "Name cannot be less than 3 characters";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    child: CustomTextStyle(
                                      text: "Dose Administered By PR Number",
                                      isBold: true,
                                      color:
                                          doseList == null ? Colors.grey : null,
                                    ),
                                  ),
                                  CustomInputField(
                                    enabled: doseList == null ? false : true,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    underlineBorder: true,
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // Only allow digits
                                    ],
                                    onSaved: (value) {
                                      if (value == null) return;
                                      doseAdministeredPrNum = value;
                                    },
                                    initialValue: doseAdministeredPrNum,
                                    label: "",
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim().length < 3) {
                                        return "PR Number Cannot be Empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: inputWidth,
                                  ),
                                  SizedBox(
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    child: CustomTextStyle(
                                      text: "Dose Administered By Date",
                                      isBold: true,
                                      color:
                                          doseList == null ? Colors.grey : null,
                                    ),
                                  ),
                                  CustomDatePicker(
                                    isDisabled: doseList == null,
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    dateTimeVal: doseAdministeredDate,
                                    fontSize: 16,
                                    onPressed: () async {
                                      doseAdministeredDate =
                                          await Helpers.openDatePicker(
                                                  context: context,
                                                  helpText:
                                                      "Select Dose Administered Date") ??
                                              doseAdministeredDate;

                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                    width: inputWidth,
                                  ),
                                  SizedBox(
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    child: const CustomTextStyle(
                                      text: "Next Dose Due Date",
                                      isBold: true,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  CustomDatePicker(
                                    isDisabled: true,
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    defaultLabel: nextDoseDueDate,
                                    fontSize: 16,
                                  ),
                                  SizedBox(
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    child: const CustomTextStyle(
                                      text: "Is This Dose Due?",
                                      isBold: true,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  CustomInputField(
                                    enabled: false,
                                    labelFontSize: 14,
                                    uiColor: widget.uiColor,
                                    textColor: isDoseDue!
                                        ? null
                                        : const Color.fromARGB(255, 255, 0, 0),
                                    underlineBorder: true,
                                    width: inputWidth > 560
                                        ? (inputWidth - 40) * .5
                                        : inputWidth,
                                    initialValue: isDoseDueText,
                                    label: "",
                                  ),
                                  CustomInputField(
                                    enabled: doseList == null ? false : true,
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
                      }
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
