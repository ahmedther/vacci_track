// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/home_nav_wrapper.dart';
import 'package:vacci_track_frontend/ui/emp_profile_card.dart';
import 'package:vacci_track_frontend/components/scroll_behavior.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/helpers/helper_widgets.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/employee_cards.dart';
import 'package:vacci_track_frontend/ui/full_screen_error.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'dart:math';

class HomePage extends ConsumerStatefulWidget {
  const HomePage(
      {this.isDoseAdminPage = false,
      this.isVaccineCompletedPage = false,
      super.key});
  static const String routeName = '/';
  static const String routeName1 = '/doses_recently_administered';
  static const String routeName2 = '/vaccination_completed';

  final bool isDoseAdminPage;
  final bool isVaccineCompletedPage;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  late final Color themeColor =
      Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int? totalNumberOfPages;
  bool isSpinning = true;
  bool isfetching = false;
  bool hasMore = true;
  List fullEmpData = [];
  int page = 1;
  final int recordsPerPage = 20;
  late final int? selectedIndex;
  late final String dueDateFilter;
  late final String doseDateFilter;
  late final String vaccComplFilter;

  @override
  void initState() {
    super.initState();
    initHandler();
    Future.delayed(Duration.zero, () async {
      await getEmpData();
    });

    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        if (!isfetching && hasMore && page <= (totalNumberOfPages ?? 1)) {
          isfetching = true;
          page++;

          final empData = await getEmployeesData(query: searchController.text);
          fullEmpData.addAll(empData);
        }
      }
      await changeStateFalse();
    });
  }

  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    scrollController.dispose();
  }

  void initHandler() {
    if (widget.isDoseAdminPage) {
      selectedIndex = 1;
      dueDateFilter = "False";
      doseDateFilter = "True";
      vaccComplFilter = "False";
      return;
    }

    if (widget.isVaccineCompletedPage) {
      selectedIndex = 2;
      dueDateFilter = "False";
      doseDateFilter = "False";
      vaccComplFilter = "True";
      return;
    }

    selectedIndex = 0;
    dueDateFilter = "True";
    doseDateFilter = "False";
    vaccComplFilter = "False";
  }

  Future<List> getEmployeesData({String? query}) async {
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccine_records/",
        query: {
          "records_per_page": recordsPerPage.toString(),
          "due_date_filter": dueDateFilter,
          "page": page.toString(),
          "query": query,
          "dose_date_filter": doseDateFilter,
          "vacc_compl_filter": vaccComplFilter,
        });
    // print(empData[0][0]);
    if (empData[0] is Map) {
      return empData;
    }
    hasMore = !((empData[0] as List).length < recordsPerPage);
    totalNumberOfPages = empData[1];
    return empData[0];
  }

  Future<void> getEmpData({String? query, bool? showError = false}) async {
    if (isfetching) return;
    isfetching = true;
    final empData = await getEmployeesData(query: query);
    if (empData.isNotEmpty) {
      if (!(empData[0] as Map).containsKey("error")) {
        fullEmpData = empData;
      } else if ((empData[0] as Map).containsKey("error")) {
        HelpersWidget.showSnackBar(context, empData[0].toString());
      }
    }
    if (empData.isEmpty && showError!) {
      HelpersWidget.showSnackBar(
          context, "No Data Found with Keyword : ${searchController.text}");
    }

    changeStateFalse();
  }

  Future<void> changeStateFalse() async {
    if (mounted) {
      setState(() {
        isSpinning = false;
        isfetching = false;
      });
    }
  }

  Future<void> onRefresh({bool resetEmp = true}) async {
    totalNumberOfPages = 0;
    hasMore = true;
    page = 1;
    isSpinning = true;
    if (resetEmp) {
      searchController.clear();

      await getEmpData();
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double containerWidth = Helpers.minAndMax(deviceWidth * .9, 100, 1290);
    return HomeWithNavWrapper(
      selectedIndex: selectedIndex,
      containerWidth: containerWidth,
      deviceHeight: deviceHeight,
      deviceWidth: deviceWidth,
      pageHeading: "Home",
      themeColor: themeColor,
      uiColor: uiColor,
      backgroundColor: backgroundColor,
      searchController: searchController,
      searchHintText: "Search For Employees With Name or UHID/PR Number",
      onChangedSearch: (String value) async {
        if (value.trim().length > 3 || value.trim() == '') {
          onRefresh(resetEmp: false);
          await getEmpData(query: value);
        }
      },
      onPressedSearch: () async {
        if (searchController.text.trim().length > 2) {
          setState(() {
            isSpinning = true;
          });
          onRefresh(resetEmp: false);
          await getEmpData(
              query: searchController.text.trim(), showError: true);
        } else {
          HelpersWidget.showSnackBar(context,
              "Please enter at least three characters to perform a search. 💉");
        }
      },
      headings: [
        "Employee Details",
        "Vaccine",
        "${widget.isVaccineCompletedPage ? "Last" : ""} Dose",
        widget.isDoseAdminPage || widget.isVaccineCompletedPage
            ? (widget.isVaccineCompletedPage ? "Completion Date" : "Dose Date")
            : "Due Date",
      ],
      children: [
        isSpinning
            ? SpinnerWithOverlay(
                spinnerColor: uiColor,
              )
            : Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 30, right: 20),
                  width: containerWidth,
                  child: fullEmpData.isNotEmpty
                      ? ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: RefreshIndicator(
                            onRefresh: onRefresh,
                            child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: fullEmpData.length + 1,
                              itemBuilder: (context, index) {
                                if (index < fullEmpData.length) {
                                  final Map<String, dynamic> dosePendings =
                                      fullEmpData[index];
                                  return EmployeeDetailCards(
                                    containerWidth: containerWidth,
                                    deviceHeight: deviceHeight,
                                    deviceWidth: deviceWidth,
                                    themeColor: themeColor,
                                    uiColor: uiColor,
                                    backgroundColor: backgroundColor,
                                    titleText:
                                        '${dosePendings['employee']['prefix'] ?? ""} ${dosePendings['employee']['first_name'] ?? ""} ${dosePendings['employee']['middle_name'] ?? ""} ${dosePendings['employee']['last_name'] ?? ""}',
                                    circleAvatarText: dosePendings['employee']
                                        ['first_name'][0],
                                    column1Texts: [
                                      [
                                        "Gender",
                                        ":",
                                        "${dosePendings['employee']['gender'] ?? 'Not Available'}"
                                      ],
                                      [
                                        "PR Number",
                                        ":",
                                        "${dosePendings['employee']['pr_number'] ?? 'Not Available'}"
                                      ],
                                      widget.isDoseAdminPage
                                          ? [
                                              "UHID",
                                              ":",
                                              "${dosePendings['employee']['uhid'] ?? 'Not Available'}"
                                            ]
                                          : [
                                              "Designation",
                                              ":",
                                              "${dosePendings['employee']['designation'] ?? 'Not Available'}"
                                            ]
                                    ],
                                    column2Texts: widget.isDoseAdminPage
                                        ? [
                                            [
                                              "Dose Administrator",
                                              ":",
                                              "${dosePendings['dose_administered_by_name'] ?? 'Not Available'}"
                                            ],
                                            [
                                              "Administrator's PR",
                                              ":",
                                              "${dosePendings['dose_administered_by_pr_number'] ?? 'Not Available'}"
                                            ],
                                            [
                                              "Due Date",
                                              ":",
                                              Helpers.getFormatedDate(
                                                  stringValue: dosePendings[
                                                      'dose_due_date'])
                                            ]
                                          ]
                                        : [
                                            [
                                              "Phone Number",
                                              ":",
                                              "${dosePendings['employee']['phone_number'] ?? 'Not Available'}"
                                            ],
                                            [
                                              "UHID",
                                              ":",
                                              "${dosePendings['employee']['uhid'] ?? 'Not Available'}",
                                            ],
                                            [
                                              "Department",
                                              ":",
                                              "${dosePendings['employee']['department'] ?? 'Not Available'}",
                                            ]
                                          ],
                                    otherColums: [
                                      "${dosePendings['vaccination']['name'] ?? 'Not Available'}",
                                      "${dosePendings['dose']['name'] ?? 'Not Available'}",
                                      widget.isDoseAdminPage ||
                                              widget.isVaccineCompletedPage
                                          ? Helpers.getFormatedDate(
                                              stringValue:
                                                  dosePendings['dose_date'])
                                          : Helpers.getFormatedDate(
                                              stringValue:
                                                  dosePendings['dose_due_date'])
                                    ],
                                    onTap: () async {
                                      if (widget.isVaccineCompletedPage ||
                                          widget.isDoseAdminPage) {
                                        final List? vaccRecords = widget
                                                .isVaccineCompletedPage
                                            ? await vaccPageHandler(
                                                dosePendings['employee']['id'])
                                            : null;
                                        empProfile(
                                          deviceWidth: deviceWidth,
                                          deviceHeight: deviceHeight,
                                          data: dosePendings,
                                          empRecords: vaccRecords,
                                        );
                                      } else {
                                        redirectToRecordVaccine(dosePendings);
                                      }
                                    },
                                  );
                                } else {
                                  return hasMore
                                      ? SpinnerWithOverlay(
                                          spinnerColor: uiColor,
                                          message:
                                              "Loading Page... $page of $totalNumberOfPages",
                                          size: 50,
                                        )
                                      : CustomTextStyle(
                                          text:
                                              "Last Page (${page < (totalNumberOfPages ?? 0) ? page : totalNumberOfPages} of $totalNumberOfPages)",
                                          color: uiColor,
                                          fontSize: 14,
                                          isBold: true,
                                          textAlign: TextAlign.center,
                                        );
                                }
                              },
                            ),
                          ),
                        )
                      : CustomErrorWidget(uiColor: uiColor),
                ),
              ),
      ],
    );
  }

  void redirectToRecordVaccine(Map<String, dynamic> data) {
    Helpers.changeNavIndex(1, ref);
    context.go(
      "/record_vaccine_dose",
      extra: {
        ...data['employee'] as Map<String, dynamic>,
        'vaccinations': [data['vaccination']],
        'dose': data['dose'],
        'department': {
          'id': Random().nextInt(100),
          'name': (data['employee'] as Map<String, dynamic>)['department']
        },
        'designation': {
          'id': Random().nextInt(100),
          'name': (data['employee'] as Map<String, dynamic>)['designation']
        },
      },
    );
  }

  Future empProfile(
      {required double deviceHeight,
      required double deviceWidth,
      required final Map<String, dynamic> data,
      List? empRecords}) async {
    late final Color profileColor = Helpers.getUIandBackgroundColor(
        data["employee"]["gender"] ?? "male")[0];

    await HelpersWidget.showDialogOnScreen(
      btnMessage: "Close",
      context: context,
      title:
          "${data["employee"]['prefix'] ?? ''} ${data["employee"]['first_name'] ?? ''} ${data["employee"]['middle_name'] ?? ''} ${data["employee"]['last_name'] ?? ''}",
      uiColor: profileColor,
      backgroundColor: themeColor,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: profileColor,
            maxRadius: deviceHeight * 0.09,
            child: CircleAvatar(
              backgroundColor: themeColor,
              maxRadius: deviceHeight * 0.08,
              child: Image.asset(
                'assets/img/${data["employee"]["gender"] ?? "both"}.png',
              ),
            ),
          ),
          if (widget.isDoseAdminPage) ...[
            ...getEmpProfileCard(
                data: data,
                deviceHeight: deviceHeight,
                deviceWidth: deviceWidth,
                profileColor: profileColor)
          ],
          if (widget.isVaccineCompletedPage) ...[
            ...getEmpProfileCard(
                empRecords: empRecords,
                deviceHeight: deviceHeight,
                deviceWidth: deviceWidth,
                profileColor: profileColor)
          ],
        ],
      ),
    );
  }

  List<Widget> getEmpProfileCard({
    final Map<String, dynamic>? data,
    required double deviceHeight,
    required double deviceWidth,
    required Color profileColor,
    List? empRecords,
  }) {
    final Map<String, dynamic> employee =
        widget.isDoseAdminPage ? data!["employee"] : empRecords![0]["employee"];
    final List<IconData> column1Icon = widget.isDoseAdminPage
        ? const [
            FontAwesomeIcons.mars,
            FontAwesomeIcons.idCardClip,
            FontAwesomeIcons.solidIdBadge,
            FontAwesomeIcons.mobileScreenButton,
            FontAwesomeIcons.userTag,
            FontAwesomeIcons.buildingUser,
            FontAwesomeIcons.buildingCircleArrowRight,
            FontAwesomeIcons.notesMedical
          ]
        : empRecords!.map((e) => FontAwesomeIcons.vialCircleCheck).toList() +
            [FontAwesomeIcons.notesMedical];
    final List<String> column1Label = widget.isDoseAdminPage
        ? const [
            "Gender",
            "PR Number",
            "UHID Number",
            "Phone Number",
            "Designation",
            "Department",
            "Facility",
            "Notes /Remarks"
          ]
        : mapData(empRecords: empRecords!, label: "vaccination") +
            ["Notes /Remarks"];
    final List<String> column1Value = widget.isDoseAdminPage
        ? [
            employee["gender"] ?? "Not Available",
            employee['pr_number'] ?? "Not Available",
            employee['uhid'] ?? "Not Available",
            employee['phone_number'] ?? "Not Available",
            employee['designation'] ?? "Not Available",
            employee['department'] ?? "Not Available",
            employee['facility'] ?? "Not Available",
          ]
        : mapData(empRecords: empRecords!, label: "dose");
    final List<IconData> column2Icon = widget.isDoseAdminPage
        ? const [
            FontAwesomeIcons.vialCircleCheck,
            FontAwesomeIcons.syringe,
            FontAwesomeIcons.userNurse,
            FontAwesomeIcons.solidIdCard,
            FontAwesomeIcons.clockRotateLeft,
            FontAwesomeIcons.solidCalendarCheck,
            FontAwesomeIcons.calendarDay,
          ]
        : empRecords!.map((e) => FontAwesomeIcons.syringe).toList();
    final List<String> column2Label = widget.isDoseAdminPage
        ? const [
            "Vaccine",
            "Dose",
            "Dose Administrator",
            "Administrator PR",
            "Dose Was Due ON",
            "Date Administered ",
            "Gap Duration",
          ]
        : mapData(
            empRecords: empRecords!,
            label: "dose_due_date",
            method: 1,
            title: "Due Date");
    final List<String> column2Value = widget.isDoseAdminPage
        ? [
            data!["vaccination"]["name"],
            data["dose"]["name"],
            data["dose_administered_by_name"],
            data["dose_administered_by_pr_number"],
            Helpers.getFormatedDate(stringValue: data["dose_due_date"]),
            Helpers.getFormatedDate(stringValue: data["dose_date"]),
            dateDifference(data["dose_due_date"], data["dose_date"]),
          ]
        : mapData(
            empRecords: empRecords!,
            label: "dose_date",
            method: 1,
            title: "Dose Date");

    return [
      EmployeeProfileCard(
        gender: employee["gender"] ?? 'male',
        column1Icon: column1Icon,
        column1Label: column1Label,
        column1Value: column1Value,
        column2Icon: column2Icon,
        column2Label: column2Label,
        column2Value: column2Value,
      ),
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: Helpers.minAndMax(deviceWidth * .8, 300, 800),
          child: CustomTextStyle(
            text: widget.isDoseAdminPage
                ? "${(data!['notes_remarks'] as String).isEmpty ? "No remarks were written for this dose administration." : data["notes_remarks"]}"
                : getNotesRemarks(empRecords!),
            color: profileColor,
            isBold: true,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    ];
  }

  Future<List> vaccPageHandler(int id) async {
    setState(() {
      isSpinning = true;
    });
    final API_URL = await Helpers.load_env();
    final List vaccRecords = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccine_records/",
        query: {
          "records_per_page": "999",
          "emp_id": id.toString(),
        });
    setState(() {
      isSpinning = false;
    });
    return vaccRecords[0];
  }
}

String dateDifference(String? date1, String? date2) {
  if (date1 == null || date2 == null) return 'Not Available';
  DateTime parsedDate1 = DateTime.parse(date1);
  DateTime parsedDate2 = DateTime.parse(date2);

  if (parsedDate2.isBefore(parsedDate1)) {
    return 'Something is Wrong';
  }

  Duration difference = parsedDate2.difference(parsedDate1);

  int years = (difference.inDays / 365).floor();
  int months = ((difference.inDays % 365) / 30).floor();
  int days = (difference.inDays % 365) % 30;

  return '${years > 0 ? "$years Years, " : ""}${months > 0 ? "$months Months, " : ""}$days Days';
}

List<String> mapData(
    {required List empRecords,
    required String label,
    int? method = 0,
    String? title}) {
  if (method == 1) {
    return empRecords
        .map((record) =>
            (" $title - ${Helpers.getFormatedDate(stringValue: record[label])} ${record[label] != null ? "✔️" : "❌"}"))
        .toList();
  }
//

  return empRecords
      .where((record) => record[label] != null)
      .map((record) => (record[label]['name'] ?? '') as String)
      .toList();
}

String getNotesRemarks(List empRecords) {
  String remarks = empRecords
      .where((record) =>
          record['notes_remarks'] != null && record['notes_remarks'] != "")
      .map((record) => (record['notes_remarks'] ?? '') as String)
      .join('\n\n');
  return remarks.trim().isEmpty
      ? 'No remarks were written for this profile'
      : remarks;
}
