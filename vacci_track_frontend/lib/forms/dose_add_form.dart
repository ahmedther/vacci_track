// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';

class DoseAddForm extends StatefulWidget {
  const DoseAddForm({required this.uiColor, required this.editPage, super.key});
  final bool editPage;

  final Color uiColor;

  @override
  State<DoseAddForm> createState() => _DoseAddFormState();
}

class _DoseAddFormState extends State<DoseAddForm> {
  bool _isSpinning = true;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _id = 0;
  String? _name;
  int? _doseNumber;
  String? _gapBeforNextDose;
  int? _totalVacDose;
  String? _detail;
  String? _vaccination;

  late final Color themeColor = Helpers.getThemeColorWithUIColor(
      context: context, uiColor: widget.uiColor);

  late List vacciData;
  late List<DropdownMenuItem<String>>? vaccinationList;

  bool isVacSelected = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getVaccinationList();
    });
  }

  Future<void> getVaccinationList() async {
    final API_URL = await Helpers.load_env();

    vacciData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccination_list/");
    bool error = await Helpers.checkError(vacciData[0], context);
    if (error) {
      return;
    }
    vaccinationList = vacciData.map((item) {
      return DropdownMenuItem<String>(
        value: item['id'].toString(),
        child: Text(item['name']),
      );
    }).toList();
    setState(() {
      _isSpinning = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDose() async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List doseList = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_dose/",
        query: {"query": _searchController.text.toString()});
    if (doseList[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      HelpersWidget.showSnackBar(context, doseList[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }
    if (doseList.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, doseList);
    } else {
      await updateForm(doseList[0]);
    }
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
          url: "http://$API_URL/api/add_dose/",
          data: {
            if (widget.editPage) "id": _id,
            "name": _name,
            "dose_number": _doseNumber!,
            "gap_before_next_dose": int.parse(_gapBeforNextDose!),
            'vaccination': _vaccination,
            "detail": _detail,
            if (widget.editPage) "edit": widget.editPage,
          });

      if (data.containsKey('error')) {
        setState(() {
          _isSpinning = false;
        });
        // ignore: use_build_context_synchronously
        HelpersWidget.showSnackBar(context, data['error']);
        return;
      } else {
        // ignore: use_build_context_synchronously
        HelpersWidget.showDialogOnScreen(
            context: context,
            btnMessage: 'OK',
            title: "✔ Successful",
            message: widget.editPage
                ? "Dose Successfully Updated"
                : "Dose Successfully Added",
            onPressed: () {});
        await resetBtnHandler();
      }
    }
  }

  Future<void> getDoseNumber(String value) async {
    setState(() {
      _isSpinning = true;
    });
    _gapBeforNextDose = null;
    final Map element =
        vacciData.firstWhere((e) => e['id'] == int.parse(value));
    _doseNumber = element['dose_count'] + 1;
    _totalVacDose = element['total_number_of_doses'];
    isVacSelected = true;

    if (_doseNumber == _totalVacDose) {
      _gapBeforNextDose = "0";
    }

    await Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        _isSpinning = false;
      });
    });
  }

  String? getDoseText() {
    if (_doseNumber == null) {
      return null;
    } else if (_totalVacDose != null &&
        _doseNumber != null &&
        _doseNumber! > _totalVacDose!) {
      return "Max Limit is $_totalVacDose";
    } else {
      return "${_doseNumber.toString()} Out Of ${_totalVacDose.toString()}";
    }
  }

  bool getEnableStatus() {
    if (!isVacSelected) {
      return false;
    } else if (_doseNumber != null &&
        _totalVacDose != null &&
        _doseNumber != _totalVacDose &&
        _doseNumber! < _totalVacDose!) {
      return true;
    }
    return false;
  }

  Future updateForm(Map data) async {
    _id = data["id"];
    _name = data["name"];
    _doseNumber = data["dose_number"];
    _gapBeforNextDose = data["gap_before_next_dose"].toString();
    _detail = data["detail"];
    _vaccination = data["vaccination"]['id'].toString();
    _totalVacDose = data["vaccination"]["total_number_of_doses"];
    isVacSelected = true;
  }

  Future resetBtnHandler() async {
    await getVaccinationList();
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
      _searchController.clear();
      _name = null;
      _doseNumber = null;
      _gapBeforNextDose = null;
      _vaccination = null;
      _detail = null;
      _isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double inputWidth = Helpers.minAndMax(deviceWidth * .4, 200, 500);
    bool isEnabled = getEnableStatus();

    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Column(
            children: [
              if (widget.editPage) ...{
                SizedBox(
                  height: deviceHeight * 0.02,
                ),
                SizedBox(
                  width: inputWidth + 20,
                  child: CustomSearchBar(
                    deviceWidth: deviceWidth,
                    onPressed: () {
                      _searchController.text.length < 3
                          ? HelpersWidget.showSnackBar(
                              context, "Please enter at least 3 characters")
                          : _searchDose();
                    },
                    controller: _searchController,
                    uiColor: widget.uiColor,
                    backgroundColor: themeColor,
                    hintText: "Search For A Dose",
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
                  color: themeColor,
                  padding: const EdgeInsets.all(40),
                  width: inputWidth + 40,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: inputWidth * .1,
                          runSpacing: 20,
                          children: [
                            CustomDropDownField(
                              disabledHint: const Text("Select A Vaccine"),
                              decoration: dropdownDecoration(
                                  isDisabled: widget.editPage,
                                  label: "Vaccination",
                                  color: widget.uiColor),
                              width: inputWidth,
                              value: _vaccination,
                              items: vaccinationList ?? [],
                              hint: "Select a Vaccination",
                              onChanged: widget.editPage
                                  ? null
                                  : (value) async {
                                      if (value != null) {
                                        _vaccination = value;
                                        await getDoseNumber(value);
                                      }
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Assign to Vaccination Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              enabled: isVacSelected,
                              label: "Name",
                              initialValue: _name,
                              width: inputWidth,
                              onSaved: (value) {
                                if (value == null) return;
                                _name = value;
                              },
                              onChanged: (value) {
                                _name = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 3) {
                                  return "Dose name can not be empty or less then 3 characters!";
                                }
                                return null;
                              },
                              uiColor: widget.uiColor,
                            ),
                            SizedBox(
                                width: inputWidth * .4,
                                child: const CustomTextStyle(
                                    color: Colors.grey,
                                    text: "Dose Number",
                                    isBold: true)),
                            CustomInputField(
                              enabled: false,
                              label: "",
                              initialValue: getDoseText(),
                              width: inputWidth * .3,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              uiColor: widget.uiColor,
                            ),
                            SizedBox(
                                width: inputWidth * .4,
                                child: CustomTextStyle(
                                    color: isEnabled ? null : Colors.grey,
                                    text:
                                        "Gap Before Next Dose is Due. In Months",
                                    isBold: true)),
                            CustomInputField(
                              enabled: isEnabled,
                              label: "",
                              initialValue:
                                  isVacSelected && _gapBeforNextDose == "0"
                                      ? "$_gapBeforNextDose Months.\nLast Dose"
                                      : _doseNumber != null &&
                                              _totalVacDose != null &&
                                              _doseNumber! > _totalVacDose!
                                          ? "Limit Reached"
                                          : _gapBeforNextDose,
                              uiColor: widget.uiColor,
                              width: inputWidth * .3,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              onSaved: (value) {
                                if (value == null) return;
                                if (value.length > 10) {
                                  _gapBeforNextDose = "0";
                                } else {
                                  _gapBeforNextDose = value;
                                }
                              },
                              onChanged: (value) {
                                _gapBeforNextDose = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "Dose name can not be empty or less then 1 characters!";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
                              enabled: isVacSelected,
                              label: "Details",
                              initialValue: _detail,
                              width: inputWidth,
                              onSaved: (value) {
                                if (value == null) return;
                                _detail = value;
                              },
                              maxLines: 5,
                              uiColor: widget.uiColor,
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
                              onPressed: isVacSelected ? resetBtnHandler : null,
                              child: CustomTextStyle(
                                  text: "Reset",
                                  color: isVacSelected
                                      ? widget.uiColor
                                      : Colors.grey,
                                  isBold: true),
                            ),
                            ElevatedButton(
                              onPressed: isVacSelected ? submitHandler : null,
                              child: CustomTextStyle(
                                  text: 'Submit',
                                  color: isVacSelected
                                      ? widget.uiColor
                                      : Colors.grey,
                                  isBold: true),
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

  Future<void> _dialogBuilder(BuildContext context, List doseData) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColor,
          title: CustomTextStyle(
              text: 'Multiple Dose Found with  "${_searchController.text}" ',
              color: widget.uiColor,
              isBold: true),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * .5,
            width: MediaQuery.of(context).size.width * .01,
            child: ListView.builder(
              itemCount: doseData.length,
              itemBuilder: (context, index) {
                Map dose = doseData[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    hoverColor: const Color.fromARGB(31, 0, 0, 0),
                    onTap: () async {
                      await updateForm(dose);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Helpers.getRandomColor(),
                      child: const FaIcon(FontAwesomeIcons.syringe,
                          color: Colors.white),
                    ),
                    title: CustomTextStyle(
                      text: dose["name"],
                      color: widget.uiColor,
                      isBold: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextStyle(
                          text: 'Dose Number : ${dose['dose_number']}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text:
                              'Gap Before Next Dose : ${dose["gap_before_next_dose"]} Month(s)',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Vaccination : ${dose['vaccination']['name']}',
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: 'Details : ${dose['detail']}',
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
              child: CustomTextStyle(
                  text: 'Cancel', isBold: true, color: widget.uiColor),
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
