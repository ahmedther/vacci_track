import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

// ignore: must_be_immutable
class VaccineAddForm extends StatefulWidget {
  VaccineAddForm({required this.editPage, super.key});
  bool editPage;

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
        query: "param1=${_searchController.text}");

    if (vaccinieData.isEmpty || vaccinieData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, vaccinieData[0]['error']);
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
        Helpers.showSnackBar(context, data['error']);
        return;
      } else {
        // ignore: use_build_context_synchronously
        Helpers.showDialogOnScreen(
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
    double inputWidth = Helpers.min_max(deviceWidth, .20, 500, 600);
    return _isSpinning
        ? const SpinnerWithOverlay(
            spinnerColor: Colors.blue,
          )
        : Card(
            borderOnForeground: true,
            elevation: 100,
            margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
            child: Container(
              padding: const EdgeInsets.all(30),
              width: inputWidth + 20,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (widget.editPage) ...{
                      SearchBar(
                        controller: _searchController,
                        elevation: const MaterialStatePropertyAll(2),
                        hintText: "Search For A Vaccine ",
                        leading: FaIcon(
                          FontAwesomeIcons.magnifyingGlass,
                          color: Theme.of(context).colorScheme.primary,
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
                                deviceWidth < 900 ? '🔎' : 'Search',
                              ),
                              onPressed: () {
                                _searchDesignation(context);
                              },
                            );
                          },
                        ),
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 32)
                    },
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      children: [
                        CustomInputField(
                          label: "Name",
                          initialValue: _name,
                          border: const OutlineInputBorder(),
                          width: Helpers.min_max(deviceWidth, .10, 350, 400),
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
                          label: "Doses",
                          initialValue: _totalDose,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Only allow digits
                          ],
                          border: const OutlineInputBorder(),
                          width: Helpers.min_max(deviceWidth, .10, 70, 70),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      label: "Other Notes",
                      initialValue: _otherNotes,
                      border: const OutlineInputBorder(),
                      width: inputWidth - 70,
                      onSaved: (value) {
                        if (value == null) return;
                        _otherNotes = value;
                      },
                      maxLines: 5,
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
            ),
          );
  }

  Future<void> _dialogBuilder(BuildContext context, List vaccineData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Multiple Vaccine Found with the keyword ${_searchController.text}"),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: vaccineData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> vaccine = vaccineData[index];
                return Card(
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
                    title: Text(
                      vaccine["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Total Number of Doses : ${vaccine['total_number_of_doses']}"),
                        Text("Other Notes : ${vaccine['other_notes'] ?? ""}"),
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
}
