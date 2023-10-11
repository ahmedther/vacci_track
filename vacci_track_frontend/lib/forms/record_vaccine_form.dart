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
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.resetAvatar();
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
      // await updateEmpForm(empData[0]);
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

  Future resetBtnHandler() async {
    setState(() {
      if (_formKey.currentState != null) {
        _formKey.currentState!.reset();
      }
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
                      SearchAnchor(
                        builder: (BuildContext _context,
                            SearchController controller) {
                          return SearchBar(
                            controller: controller,
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
                                  child:
                                      Text(deviceWidth < 900 ? '🔎' : 'Search'),
                                  onPressed: () {
                                    searchEmployee(context, controller.text,
                                        spinning: true);
                                  },
                                );
                              },
                            ),
                            onChanged: (_) async {
                              if (controller.text.length <= 3) return;
                              await searchEmployee(context, controller.text);
                              if (empData1 == null || empData1!.isEmpty) return;

                              controller.openView();
                            },
                          );
                        },
                        suggestionsBuilder: (BuildContext context,
                            SearchController controller) {
                          bool textSelectionExecuted = false;
                          return empData1!.map(
                            (e) {
                              if (!textSelectionExecuted) {
                                controller.selection = TextSelection.collapsed(
                                    offset: controller.text.length);
                                textSelectionExecuted = true;
                              }
                              return Card(
                                child: ListTile(
                                  hoverColor: const Color.fromARGB(31, 0, 0, 0),
                                  onTap: () async {
                                    // _useUpdateOthers
                                    //     ? await updateOtherDeatils(user)
                                    //     : null;
                                    // await updateEmpForm(user);
                                    // // ignore: use_build_context_synchronously
                                    // context.pop();
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Helpers.getRandomColor(),
                                    child: e['first_name'] != null
                                        ? Text(e['first_name'][0],
                                            style: const TextStyle(
                                                color: Colors.white))
                                        : const FaIcon(FontAwesomeIcons.userAlt,
                                            color: Colors.white),
                                  ),
                                  title: Text(
                                      '${e['prefix'] ?? ""} ${e['first_name'] ?? ""} ${e['middle_name'] ?? ""}  ${e['last_name'] ?? ""}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UHID: ${e['uhid'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'PR Number: ${e['pr_number'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (!_isForm) ...{
                        const SizedBox(height: 50),
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
