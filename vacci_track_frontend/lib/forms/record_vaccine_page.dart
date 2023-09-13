import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';

import '../ui/spinner.dart';

// ignore: must_be_immutable
class RecordVaccineForm extends StatefulWidget {
  RecordVaccineForm(
      {required this.editPage,
      required this.assignAvatar,
      required this.resetAvatar,
      super.key});

  final Function assignAvatar;
  final Function resetAvatar;
  bool editPage;

  @override
  State<RecordVaccineForm> createState() => _RecordVaccineFormState();
}

class _RecordVaccineFormState extends State<RecordVaccineForm> {
  TextEditingController _searchControllerEmp = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isSpinning = false;
  bool _isForm = false;

  String? prefix;
  String? firstName;
  String? middleName;
  String? lastName;
  String? gender;

  List? empData1;

  @override
  void dispose() {
    _searchControllerEmp.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.resetAvatar();
    });
  }

  void searchEmployee(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_employee/",
        query: "param1=${_searchControllerEmp.text}");
    if (empData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, empData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }
    print(empData);
    _isForm = true;
    empData1 = empData;
    // await updateOtherDeatils(empData[0]);
    // await updateEmpForm(empData[0]);
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

  Future resetBtnHandler() async {
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
      _searchControllerEmp.clear();
      prefix = null;
      firstName = "";
      middleName = "";
      lastName = "";
      gender = null;
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
    double inputWidth = Helpers.min_max(deviceWidth, .20, 500, 600);
    ColorScheme themeColor = Theme.of(context).colorScheme;
    return _isSpinning
        ? const SpinnerWithOverlay(
            spinnerColor: Colors.blue,
          )
        : Column(
            children: [
              if (_isForm) ...{Text(empData1.toString())},
              Card(
                borderOnForeground: true,
                elevation: 100,
                margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  width: deviceWidth * 0.70,
                  child: Column(
                    children: [
                      SearchBar(
                        controller: _searchControllerEmp,
                        hintText: "Search Employee",
                        leading: FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: themeColor.primary,
                        ),
                        trailing: Iterable.generate(
                          1,
                          (index) {
                            return OutlinedButton(
                              style: const ButtonStyle(
                                enableFeedback: true,
                                animationDuration: Duration(seconds: 2),
                              ),
                              child: Text(deviceWidth < 900 ? '🔎' : 'Search'),
                              onPressed: () {
                                searchEmployee(context);
                              },
                            );
                          },
                        ),
                      ),
                      if (!_isForm) ...{
                        SizedBox(height: 50),
                        FaIcon(
                          FontAwesomeIcons.circleArrowDown,
                          color: themeColor.primary,
                          size: 50,
                        ),
                      },
                      if (_isForm) ...{
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: [Text("Childerens")],
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
                      }
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
