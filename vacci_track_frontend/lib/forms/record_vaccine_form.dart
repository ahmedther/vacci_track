import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/components/record_vac_form_profile.dart';
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.resetAvatar();
    });
  }

  Future updateEmpForm(Map empData) async {
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
    await widget.assignAvatar(
      newgender: gender ?? "",
      newprefix: prefix ?? "",
      newfirstName: firstName ?? "",
      newmiddleName: middleName ?? "",
      newlastName: lastName ?? "",
    );
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
      _isForm = false;
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
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    late final Color profileColor =
        Helpers.getUIandBackgroundColor(gender ?? "male")[0];
    late final themeColor = Helpers.getThemeColorWithUIColor(
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
                  color: themeColor,
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
                              color: widget.uiColor,
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
                            // onChanged: (_) async {
                            //   if (controller.text.length <= 3) return;
                            //   await searchEmployee(context, controller.text);
                            //   if (empData1 == null || empData1!.isEmpty) return;
                            //   controller.openView();
                            // },
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
                                child: ListTile(
                                  hoverColor: const Color.fromARGB(31, 0, 0, 0),
                                  onTap: () async {
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
                                        ? Text(item['first_name'][0],
                                            style: const TextStyle(
                                                color: Colors.white))
                                        : const FaIcon(FontAwesomeIcons.userAlt,
                                            color: Colors.white),
                                  ),
                                  title: Text(
                                      '${item['prefix'] ?? ""} ${item['first_name'] ?? ""} ${item['middle_name'] ?? ""}  ${item['last_name'] ?? ""}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UHID: ${item['uhid'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'PR Number: ${item['pr_number'] ?? ''}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
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
                          FontAwesomeIcons.circleArrowDown,
                          color: widget.uiColor,
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
