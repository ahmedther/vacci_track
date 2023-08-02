import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/ui/employee_add_form.dart';

class AddNewEmployee extends StatefulWidget {
  const AddNewEmployee({super.key});

  @override
  State<AddNewEmployee> createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  String gender = "";
  String prefix = "";
  String firstName = "";
  String middleName = "";
  String lastName = "";

  final List<bool> _selectedToggle = <bool>[true, false];

  Future assignAvatar({
    String? newgender,
    String? newprefix,
    String? newfirstName,
    String? newmiddleName,
    String? newlastName,
  }) async {
    setState(() {
      if (newgender != null) gender = newgender;
      if (newprefix != null) {
        prefix = newprefix;
        if (prefix == "Mrs." || prefix == "Ms" || prefix == "Ms.")
          gender = "female";
        if (prefix == "Mr." || prefix == "Mr") gender = "male";
      }
      ;
      if (newfirstName != null) firstName = newfirstName;
      if (newmiddleName != null) middleName = newmiddleName;
      if (newlastName != null) lastName = newlastName;
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          color: Theme.of(context).colorScheme.background,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(deviceHeight * .02),
                child: Text(
                  "Add/Edit Employee",
                  style: TextStyle(
                    fontSize: deviceHeight * .03,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.blue,
                maxRadius: deviceHeight * 0.09,
                child: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  maxRadius: deviceHeight * 0.08,
                  child: Image.asset(
                    'assets/img/${gender.isNotEmpty ? gender : "both"}.png',
                  ),
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.01,
              ),
              Text(
                "$prefix $firstName $middleName $lastName",
                style: TextStyle(
                  fontSize: deviceHeight * 0.02,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              ToggleButtons(
                isSelected: _selectedToggle,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedToggle.length; i++) {
                      _selectedToggle[i] = i == index;
                    }
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Add A New"),
                        SizedBox(width: 10),
                        FaIcon(FontAwesomeIcons.userPlus)
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Edit Old"),
                        SizedBox(width: 10),
                        FaIcon(FontAwesomeIcons.userEdit)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              _selectedToggle[0]
                  ? EmployeeAddForm(
                      assignAvatar: assignAvatar,
                      editPage: false,
                    )
                  : EmployeeAddForm(
                      assignAvatar: assignAvatar,
                      editPage: true,
                    )
            ],
          ),
        ),
      ],
    );
  }
}
