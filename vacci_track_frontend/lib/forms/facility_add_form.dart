import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

// ignore: must_be_immutable
class FacilityAddForm extends StatefulWidget {
  FacilityAddForm({required this.editPage, super.key});
  bool editPage;

  @override
  State<FacilityAddForm> createState() => _FacilityAddFormState();
}

class _FacilityAddFormState extends State<FacilityAddForm> {
  bool _isSpinning = false;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _facilityId;
  int? _id = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future updateForm(Map data) async {
    _id = data["id"];
    _name = data["name"];
    _facilityId = data["facility_id"];
  }

  void _searchDesignation(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List facilityData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_facility/",
        query: "param1=${_searchController.text}");

    if (facilityData.isEmpty || facilityData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, facilityData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    if (facilityData.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, facilityData);
    } else {
      await updateForm(facilityData[0]);
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
          url: "http://$API_URL/api/add_facility/",
          data: {
            if (widget.editPage) "id": _id,
            "name": _name,
            "facility_id": _facilityId,
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
                ? "Facility Successfully Updated"
                : "Facility Successfully Added",
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
      _name = null;
      _facilityId = null;
      _id = null;
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
                        hintText: "Search For A Facility ",
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
                    CustomInputField(
                      label: "Name",
                      initialValue: _name,
                      border: const OutlineInputBorder(),
                      width: inputWidth,
                      onSaved: (value) {
                        if (value == null) return;
                        _name = value;
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 3) {
                          return "Facility name can not be empty or less then 3 characters!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      label: "Facility Code",
                      initialValue: _facilityId,
                      border: const OutlineInputBorder(),
                      width: inputWidth,
                      onSaved: (value) {
                        if (value == null) return;
                        _facilityId = value;
                      },
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length < 2) {
                          return "Facility Code can not be empty or less then 2 characters!";
                        }
                        return null;
                      },
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

  Future<void> _dialogBuilder(BuildContext context, List facilityData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Multiple Facility Found with the keyword ${_searchController.text}"),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: facilityData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> facility = facilityData[index];
                return Card(
                  child: ListTile(
                    hoverColor: const Color.fromARGB(31, 0, 0, 0),
                    onTap: () async {
                      await updateForm(facility);
                      // ignore: use_build_context_synchronously
                      context.pop();
                    },
                    leading: CircleAvatar(
                      backgroundColor: Helpers.getRandomColor(),
                      child: const FaIcon(
                        FontAwesomeIcons.buildingUser,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      facility["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Facility Code : ${facility["facility_id"] ?? ''}"),
                        ]),
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
