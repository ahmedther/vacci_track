// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/components/home_nav_wrapper.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/date_picker.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/ui/text_input.dart';

class DownloadReportsPage extends ConsumerStatefulWidget {
  const DownloadReportsPage({super.key});
  static const String routeName = '/download_reports';

  @override
  ConsumerState<DownloadReportsPage> createState() =>
      _DownloadReportsPageState();
}

class _DownloadReportsPageState extends ConsumerState<DownloadReportsPage> {
  bool isSpinning = false;
  bool dateError = false;
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  late final Color themeColor =
      Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);

  DateTime? fromDate;
  DateTime? toDate;
  String? filter = "all";
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double containerWidth = Helpers.minAndMax(deviceWidth * .9, 100, 1290);

    return HomeWithNavWrapper(
      selectedIndex: 3,
      containerWidth: containerWidth,
      deviceHeight: deviceHeight,
      deviceWidth: deviceWidth,
      pageHeading: "Download Reports",
      themeColor: themeColor,
      uiColor: uiColor,
      backgroundColor: backgroundColor,
      children: [
        Card(
          borderOnForeground: true,
          elevation: 100,
          margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.05),
          child: Container(
            color: themeColor,
            padding: const EdgeInsets.all(30),
            width: containerWidth * .5,
            child: isSpinning
                ? SpinnerWithOverlay(
                    spinnerColor: uiColor,
                    message: "Fetching Data.\nPlease Wait...",
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          CustomDatePicker(
                            width: Helpers.minAndMax(
                                containerWidth * .21, 125, 500),
                            defaultLabel: fromDate != null
                                ? Helpers.getFormatedDate(dateValue: fromDate)
                                : "From Date",
                            onPressed: () async {
                              dateError = false;
                              fromDate = await HelpersWidget.openDatePicker(
                                  context: context,
                                  helpText: "Select From Date");
                              if (fromDate != null) {
                                setState(() {});
                              }
                            },
                          ),
                          CustomDatePicker(
                            width: Helpers.minAndMax(
                                containerWidth * .21, 125, 500),
                            defaultLabel: toDate != null
                                ? Helpers.getFormatedDate(dateValue: toDate)
                                : "To Date",
                            onPressed: () async {
                              dateError = false;
                              toDate = await HelpersWidget.openDatePicker(
                                  context: context, helpText: "Select To Date");
                              if (fromDate != null) {
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                      if (dateError) ...{
                        const CustomTextStyle(
                          text:
                              "Error: The 'From Date' or 'To Date' fields cannot be left empty. Please enter a valid date.",
                          color: Colors.red,
                          fontSize: 12,
                          isBold: true,
                        ),
                      },
                      SizedBox(
                        height: deviceHeight * 0.04,
                      ),
                      SizedBox(
                        width:
                            Helpers.minAndMax(containerWidth * .44, 125, 1000),
                        child: Column(
                          children: [
                            const CustomTextStyle(
                                text: 'Renine Results',
                                isBold: true,
                                fontSize: 16),
                            const Divider(color: Colors.black, thickness: 1),
                            ...genRadioTile([
                              {
                                "title": "Pending Doses",
                                "value": "due_date_filter"
                              },
                              {
                                "title": "Administered Doses",
                                "value": "dose_date_filter"
                              },
                              {"title": "All", "value": "all"},
                            ])
                          ],
                        ),
                      ),
                      CustomInputField(
                        controller: controller,
                        lableIsBold: true,
                        labelFontSize: 14,
                        uiColor: uiColor,
                        underlineBorder: true,
                        width: containerWidth,
                        label: "Refine Resutls With Keyword",
                      ),
                      SizedBox(
                        height: deviceHeight * 0.04,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 40,
                        children: [
                          TextButton(
                            onPressed: resetBtnHandler,
                            child: CustomTextStyle(
                                text: "Reset", color: uiColor, isBold: true),
                          ),
                          ElevatedButton(
                            onPressed: submitHandler,
                            child: CustomTextStyle(
                                text: 'Submit', color: uiColor, isBold: true),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  List<RadioListTile> genRadioTile(List<Map<String, String>> values) {
    return values.map((e) {
      return RadioListTile(
        title: CustomTextStyle(text: e["title"]!, isBold: true),
        value: e["value"],
        groupValue: filter,
        onChanged: (value) {
          setState(() {
            filter = value.toString();
          });
        },
      );
    }).toList();
  }

  void resetBtnHandler() {
    setState(() {
      dateError = false;
      fromDate = null;
      toDate = null;
      filter = "all";
      controller.clear();
    });
  }

  void submitHandler() async {
    if (fromDate == null || toDate == null) {
      {
        setState(() {
          dateError = true;
        });
      }

      return;
    }
    setState(() {
      isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List data = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_report/",
        fileResponce: true,
        query: {
          "from_date": fromDate.toString(),
          "to_date": toDate.toString(),
          "query": controller.text,
          "filter": filter,
        });
    if (data.isEmpty || (data[0] as Map).containsKey("error")) {
      HelpersWidget.showSnackBar(
          context,
          data.isEmpty
              ? "No Records Found between ${Helpers.getFormatedDate(dateValue: fromDate)} and ${Helpers.getFormatedDate(dateValue: toDate)}"
              : data[0]['error']);
    }
    setState(() {
      isSpinning = false;
    });
  }
}
