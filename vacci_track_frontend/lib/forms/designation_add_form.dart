import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

class DesignationAddForm extends StatefulWidget {
  final bool editPage;
  final Color uiColor;
  const DesignationAddForm(
      {required this.uiColor, required this.editPage, super.key});

  @override
  State<DesignationAddForm> createState() => _DesignationAddFormState();
}

class _DesignationAddFormState extends State<DesignationAddForm> {
  bool _isSpinning = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  int? _id = 0;

  late final Color themeColor = Helpers.getThemeColorWithUIColor(
      context: context, uiColor: widget.uiColor);

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitHandler() async {
    if (_nameController.text == "") {
      HelpersWidget.showSnackBar(context,
          "Designation Name was left empty!!! Please enter a Name for the Designation.");
      return;
    }
    if (_nameController.text.length < 3) {
      HelpersWidget.showSnackBar(context,
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
      HelpersWidget.showSnackBar(context, data['error']);
    } else {
      // ignore: use_build_context_synchronously
      HelpersWidget.showDialogOnScreen(
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
        query: {"query": "param1=${_searchController.text}"});

    if (_designationData.isEmpty || _designationData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      HelpersWidget.showSnackBar(context, _designationData[0]['error']);
      setState(() {
        _isSpinning = false;
      });
      return;
    }

    if (_designationData.length > 1) {
      // ignore: use_build_context_synchronously
      await _dialogBuilder(context, _designationData);
    } else {
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
    double inputWidth = Helpers.minAndMax(deviceWidth * .4, 200, 500);

    return _isSpinning
        ? SpinnerWithOverlay(
            spinnerColor: widget.uiColor,
          )
        : Card(
            borderOnForeground: true,
            elevation: 100,
            margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
            child: Container(
              color: themeColor,
              padding: const EdgeInsets.all(30),
              width: inputWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.editPage) ...{
                    CustomSearchBar(
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
                      hintText: "Search For Designation",
                    ),
                    const SizedBox(height: 32)
                  },
                  CustomInputField(
                    controller: _nameController,
                    label: "Name",
                    width: inputWidth,
                    uiColor: widget.uiColor,
                    onSaved: (_) {},
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitHandler,
                    child: CustomTextStyle(
                        text: 'Submit', color: widget.uiColor, isBold: true),
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
          backgroundColor: themeColor,
          title: CustomTextStyle(
              text:
                  "Multiple Designations Found with the keyword '${_searchController.text}'",
              color: widget.uiColor,
              isBold: true),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: _designationData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> designationData = _designationData[index];
                return Card(
                  color: Colors.white,
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
                    title: CustomTextStyle(
                      text: designationData["name"],
                      color: widget.uiColor,
                      isBold: true,
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
