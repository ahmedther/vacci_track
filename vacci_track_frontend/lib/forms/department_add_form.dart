import 'package:flutter/material.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/drop_down_field.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ignore: must_be_immutable
class DepartmentAddForm extends StatefulWidget {
  DepartmentAddForm({required this.editPage, super.key});
  bool editPage;

  @override
  State<DepartmentAddForm> createState() => _DepartmentAddFormState();
}

class _DepartmentAddFormState extends State<DepartmentAddForm> {
  bool isSpinning = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _searchControllerHOD = TextEditingController();

  void _searchHOD(BuildContext context) async {
    setState(() {
      isSpinning = true;
    });
    print(_searchControllerHOD.text);
    final API_URL = await Helpers.load_env();
    final List hodData = await Helpers.makeGetRequest(
        "http://$API_URL/api/search_hod/",
        query: "param1=${_searchControllerHOD.text}");
    print(hodData);
    if (hodData[0].containsKey("error")) {
      // ignore: use_build_context_synchronously
      Helpers.showSnackBar(context, hodData[0]['error']);
      setState(() {
        isSpinning = false;
      });
      return;
    }

    // await updateOtherDeatils(empData[0]);
    // await updateEmpForm(empData[0]);
    setState(() {
      isSpinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double inputWidth = Helpers.min_max(deviceWidth, .20, 500, 600);

    return isSpinning
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
                    CustomInputField(
                      width: inputWidth,
                      onSaved: (value) {},
                      label: "Name",
                      border: const OutlineInputBorder(),
                    ),
                    const SizedBox(height: 40),
                    SearchBar(
                      controller: _searchControllerHOD,
                      elevation: const MaterialStatePropertyAll(2),
                      hintText: "Enter PR No Or Name",
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
                              widget.editPage
                                  ? "${deviceWidth < 900 ? '🔎' : 'Search'}"
                                  : "${deviceWidth < 900 ? '🔎' : 'Search in Employees'}",
                            ),
                            onPressed: () {
                              _searchHOD(context);
                            },
                          );
                        },
                      ),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 20),
                    CustomDropDownField(
                      decoration: const InputDecoration(
                        labelText: 'Head of Department',
                        border: OutlineInputBorder(),
                      ),
                      items: [],
                      width: inputWidth,
                      hint: "Head Of Department",
                      onChanged: (value) {},
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
                          onPressed: () {},
                          child: const Text('Reset'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
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
}
