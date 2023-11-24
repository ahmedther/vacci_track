import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/dropdown_decoration.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
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
  String? _doseNumber;
  String? _gapBeforNextDose;
  String? _detail;
  String? _vaccination;

  late Color themeContainerColor;

  late List<DropdownMenuItem<String>>? vaccinationList;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getVaccinationList();
    });
  }

  Future<void> getVaccinationList() async {
    final API_URL = await Helpers.load_env();

    final List vacciData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccination_list/");
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

  Future<void> _searchDose(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List doseList = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_dose/",
        query: "param1=${_searchController.text}");

    if (doseList[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, doseList[0]['error']);
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
            "dose_number": int.parse(_doseNumber!),
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
        Helpers.showSnackBar(context, data['error']);
        return;
      } else {
        // ignore: use_build_context_synchronously
        Helpers.showDialogOnScreen(
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

  Future updateForm(Map data) async {
    _id = data["id"];
    _name = data["name"];
    _doseNumber = data["dose_number"].toString();
    _gapBeforNextDose = data["gap_before_next_dose"].toString();
    _detail = data["detail"];
    _vaccination = data["vaccination"]['id'].toString();
  }

  Future resetBtnHandler() async {
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
    double inputWidth = Helpers.min_max(deviceWidth, .20, 500, 600);
    themeContainerColor = Helpers.getThemeColorWithUIColor(
        context: context, uiColor: widget.uiColor);
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
                      _searchDose(context);
                    },
                    controller: _searchController,
                    uiColor: widget.uiColor,
                    backgroundColor: themeContainerColor,
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
                  color: themeContainerColor,
                  padding: const EdgeInsets.all(30),
                  width: inputWidth + 20,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            CustomInputField(
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
                                    value.trim().isEmpty) {
                                  return "Dose name can not be empty or less then 1 characters!";
                                }
                                return null;
                              },
                              uiColor: widget.uiColor,
                            ),
                            SizedBox(
                                width: inputWidth * .4,
                                child: const CustomTextStyle(
                                    text: "Dose Number", isBold: true)),
                            CustomInputField(
                              label: "",
                              initialValue: _doseNumber,
                              width: inputWidth * .15,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              onSaved: (value) {
                                if (value == null) return;
                                _doseNumber = value;
                              },
                              onChanged: (value) {
                                _doseNumber = value;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().isEmpty) {
                                  return "Dose name can not be empty or less then 1 characters!";
                                }
                                return null;
                              },
                              uiColor: widget.uiColor,
                            ),
                            SizedBox(width: inputWidth * .23),
                            SizedBox(
                                width: inputWidth * .4,
                                child: const CustomTextStyle(
                                    text:
                                        "Gap Before Next Dose is Due. In Months",
                                    isBold: true)),
                            CustomInputField(
                              label: "",
                              initialValue: _gapBeforNextDose,
                              width: inputWidth * .15,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              onSaved: (value) {
                                if (value == null) return;
                                _gapBeforNextDose = value;
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
                            CustomDropDownField(
                              decoration: dropdownDecoration(
                                  label: "Vaccination", color: widget.uiColor),
                              width: inputWidth,
                              value: _vaccination,
                              items: vaccinationList ?? [],
                              hint: "Select a Vaccination",
                              onChanged: (value) {
                                _vaccination = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Assign to Vaccination Cannot be Empty";
                                }
                                return null;
                              },
                            ),
                            CustomInputField(
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
          backgroundColor: themeContainerColor,
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
