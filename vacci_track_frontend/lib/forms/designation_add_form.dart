import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:vacci_track_frontend/components/ui_scaler.dart";

// ignore: must_be_immutable
class DesignationAddForm extends StatefulWidget {
  bool editPage;
  DesignationAddForm({required this.editPage, super.key});

  @override
  State<DesignationAddForm> createState() => _DesignationAddFormState();
}

class _DesignationAddFormState extends State<DesignationAddForm> {
  bool _isSpinning = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int? _id = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitHandler() async {
    if (_nameController.text == "") {
      Helpers.showSnackBar(context,
          "Designation Name was left empty!!! Please enter a Name for the Designation.");
      return;
    }
    if (_nameController.text.length < 3) {
      Helpers.showSnackBar(context,
          "Designation Name should be at least 3 characters long. Please enter a valid Name for the Designation");
      return;
    }
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final Map data = await Helpers.makePostRequest(
        url: "http://$API_URL/api/add_designation/",
        data: {
          if (widget.editPage) "id": _id,
          "name": _nameController.text,
          if (widget.editPage) "edit": widget.editPage,
        });
    if (data.containsKey('error')) {
      setState(() {
        _isSpinning = false;
      });
      Helpers.showSnackBar(context, data['error']);
    } else {
      // ignore: use_build_context_synchronously
      Helpers.showDialogOnScreen(
          context: context,
          btnMessage: 'OK',
          title: "✔ Successful",
          message: widget.editPage
              ? "Designation Successfully Updated"
              : "Designation Successfully Added",
          onPressed: () {
            _searchController.text = "";
            _nameController.text = "";
          });
      setState(() {
        _isSpinning = false;
      });
    }
  }

  Future updateForm(data) async {
    _nameController.text = data["name"];
    _id = data["id"];
  }

  void _searchDesignation(BuildContext context) async {
    setState(() {
      _isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List _designationData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_designation/",
        query: "param1=${_searchController.text}");

    if (_designationData.isEmpty || _designationData[0].containsKey("error")) {
      Helpers.showSnackBar(context, _designationData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    if (_designationData.length > 1)
      await _dialogBuilder(context, _designationData);
    else {
      await updateForm(_designationData[0]);
    }

    setState(() {
      _isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
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
              width: Helpers.min_max(deviceWidth, 50, 200, 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.editPage) ...{
                    SearchBar(
                      controller: _searchController,
                      elevation: const MaterialStatePropertyAll(2),
                      hintText: "Search For Designation",
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
                            child: Text(deviceWidth < 900 ? '🔎' : 'Search'),
                            onPressed: () {
                              _searchDesignation(context);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32)
                  },
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitHandler,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _dialogBuilder(
      BuildContext context, List _designationData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Multiple Designations Found with the keyword ${_searchController.text}"),
          content: UiScaler(
            alignment: Alignment.center,
            child: SizedBox(
              height: 200,
              width: 200,
              child: ListView.builder(
                itemCount: _designationData.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> designationData =
                      _designationData[index];
                  return Card(
                    child: ListTile(
                      hoverColor: const Color.fromARGB(31, 0, 0, 0),
                      onTap: () async {
                        await updateForm(designationData);
                        // ignore: use_build_context_synchronously
                        context.pop();
                      },
                      leading: CircleAvatar(
                        backgroundColor: Helpers.getRandomColor(),
                        child: const FaIcon(
                          FontAwesomeIcons.userTag,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        designationData["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
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
