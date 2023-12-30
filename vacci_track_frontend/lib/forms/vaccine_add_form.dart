import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

class VaccineAddForm extends StatefulWidget {
  const VaccineAddForm(
      {required this.uiColor, required this.editPage, super.key});
  final bool editPage;
  final Color uiColor;

  @override
  State<VaccineAddForm> createState() => _VaccineAddFormState();
}

class _VaccineAddFormState extends State<VaccineAddForm> {
  bool _isSpinning = false;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int? _id = 0;
  String? _name;
  String? _totalDose;
  String? _otherNotes;

  late final Color themeColor = Helpers.getThemeColorWithUIColor(
      context: context, uiColor: widget.uiColor);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future updateForm(Map data) async {
    _id = data["id"];
    _name = data["name"];
    _totalDose = data["total_number_of_doses"].toString();
    _otherNotes = data["other_notes"];
  }

  void _searchDesignation(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List vaccinieData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_vaccine/",
        query: {"query": "param1=${_searchController.text}"});

    if (vaccinieData.isEmpty || vaccinieData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      HelpersWidget.showSnackBar(context, vaccinieData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    if (vaccinieData.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, vaccinieData);
    } else {
      await updateForm(vaccinieData[0]);
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
          url: "http://$API_URL/api/add_vaccine/",
          data: {
            if (widget.editPage) "id": _id,
            "name": _name,
            "total_number_of_doses": int.parse(_totalDose!),
            "other_notes": _otherNotes,
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
                ? "Vaccine Successfully Updated"
                : "Vaccine Successfully Added",
            onPressed: () {});
        await resetBtnHandler();
      }
    }
  }

  Future resetBtnHandler() async {
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
      _id = null;
      _name = null;
      _totalDose = null;
      _otherNotes = null;
      _searchController.clear();
      _isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double inputWidth = Helpers.minAndMax(deviceWidth * .4, 200, 500);

    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Card(
            borderOnForeground: true,
            elevation: 100,
            child: Container(
              color: themeColor,
              width: inputWidth + 30,
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.editPage) ...{
                      CustomSearchBar(
                        hintText: "Search For A Vaccine ",
                        deviceWidth: deviceWidth,
                        onPressed: () {
                          _searchController.text.length < 3
                              ? HelpersWidget.showSnackBar(
                                  context, "Please enter at least 3 characters")
                              : _searchDesignation(context);
                        },
                        controller: _searchController,
                        uiColor: widget.uiColor,
                        backgroundColor: themeColor,
                      ),
                      const SizedBox(height: 32)
                    },
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      runSpacing: 20,
                      children: [
                        CustomInputField(
                          uiColor: widget.uiColor,
                          label: "Name",
                          initialValue: _name,
                          width: inputWidth > 400
                              ? (inputWidth - 40) * .7
                              : inputWidth,
                          onSaved: (value) {
                            if (value == null) return;
                            _name = value;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 3) {
                              return "Vaccine name can not be empty or less then 3 characters!";
                            }
                            return null;
                          },
                        ),
                        CustomInputField(
                          uiColor: widget.uiColor,
                          label: "Total Doses",
                          initialValue: _totalDose,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Only allow digits
                          ],
                          width: inputWidth > 400
                              ? (inputWidth - 40) * .3
                              : inputWidth,
                          onSaved: (value) {
                            if (value == null) return;
                            _totalDose = value;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().isEmpty) {
                              return "Total Number of Doese Cannot be Empty";
                            }
                            return null;
                          },
                        ),
                        CustomInputField(
                          uiColor: widget.uiColor,
                          label: "Other Notes",
                          initialValue: _otherNotes,
                          width: inputWidth,
                          onSaved: (value) {
                            if (value == null) return;
                            _otherNotes = value;
                          },
                          maxLines: 5,
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
          );
  }

  Future<void> _dialogBuilder(BuildContext context, List vaccineData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColor,
          title: CustomTextStyle(
              text:
                  "Multiple Vaccine Found with the keyword '${_searchController.text}'",
              color: widget.uiColor,
              isBold: true),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: vaccineData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> vaccine = vaccineData[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    hoverColor: const Color.fromARGB(31, 0, 0, 0),
                    onTap: () async {
                      await updateForm(vaccine);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Helpers.getRandomColor(),
                      child: const FaIcon(
                        FontAwesomeIcons.vialCircleCheck,
                        color: Colors.white,
                      ),
                    ),
                    title: CustomTextStyle(
                      text: vaccine["name"],
                      color: widget.uiColor,
                      isBold: true,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextStyle(
                          text:
                              "Total Number of Doses : ${vaccine['total_number_of_doses']}",
                          color: Colors.black,
                          isBold: true,
                        ),
                        CustomTextStyle(
                          text: "Other Notes : ${vaccine['other_notes'] ?? ""}",
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
          actions: [
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
