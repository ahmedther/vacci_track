import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/ui/badge.dart';

class EmployeeProfileCard extends StatelessWidget {
  final List<IconData>? column1Icon;
  final List<String>? column1Label;
  final List<String>? column1Value;
  final List<IconData>? column2Icon;
  final List<String>? column2Label;
  final List<String>? column2Value;
  final String? gender;

  EmployeeProfileCard(
      {this.column1Icon,
      this.column1Label,
      this.column1Value,
      this.column2Icon,
      this.column2Label,
      this.column2Value,
      this.gender = 'male',
      super.key});

  late final Color gradientColor = Helpers.getGraditentWithGender(gender!);
  late final Color profileColor = Helpers.getUIandBackgroundColor(gender!)[0];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (MediaQuery.of(context).size.width > 878) ...[
            ...buildColumnsWithSpacing(
                icon: column1Icon, label: column1Label, values: column1Value),
            const SizedBox(width: 100),
            ...buildColumnsWithSpacing(
                icon: column2Icon, label: column2Label, values: column2Value),
          ] else ...[
            ...buildColumnsWithSpacing(
                icon: (column2Icon ?? []) + (column1Icon ?? []),
                label: (column2Label ?? []) + (column1Label ?? []),
                values: (column2Value ?? []) + (column1Value ?? [])),
          ]
        ],
      ),
    );
  }

  List<Widget> buildColumnsWithSpacing({
    List<IconData>? icon,
    List<String>? label,
    List<String>? values,
  }) {
    List<Widget> columns = [];

    if (icon != null) {
      columns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: icon
            .map<Widget>((e) => FaIcon(e, color: profileColor))
            .expand((widget) => [widget, const SizedBox(height: 20)])
            .toList()
          ..removeLast(),
      ));
      columns.add(const SizedBox(width: 20));
    }

    if (label != null) {
      columns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: label
            .map<Widget>((e) => Text(
                  e,
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold),
                ))
            .expand((widget) => [widget, const SizedBox(height: 24)])
            .toList()
          ..removeLast(),
      ));
      columns.add(const SizedBox(width: 20));
    }
    if (label != null) {
      columns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: label
            .map<Widget>((_) => Text(
                  ":",
                  style: TextStyle(
                      color: profileColor, fontWeight: FontWeight.bold),
                ))
            .expand((widget) => [widget, const SizedBox(height: 24)])
            .toList()
          ..removeLast(),
      ));
      columns.add(const SizedBox(width: 20));
    }

    if (values != null) {
      columns.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: values
            .map<Widget>(
              (e) => e == "" ? const Text("") : CustomBadge(
                  text: e, // gender
                  gradientColors: [gradientColor, profileColor]),
            )
            .expand((widget) => [widget, const SizedBox(height: 20)])
            .toList()
          ..removeLast(),
      ));
      columns.add(const SizedBox(width: 20));
    }

    if (columns.isNotEmpty) {
      columns.removeLast(); // Remove the last SizedBox
    }
    return columns;
  }
}
