// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vacci_track_frontend/components/home_nav_wrapper.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/home_navigation_data.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/employee_cards.dart';
import 'package:vacci_track_frontend/ui/full_screen_error.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'dart:math';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/';

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

  late final List<NavigationDestination> homeNavigationList =
      getHomNavigationDestination(uiColor);

  Future<List> getEmployeesData({String? query}) async {
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccine_records/",
        query: {
          "records_per_page": recordsPerPage.toString(),
          "due_date_filter": "True",
          "page": page.toString(),
          "query": query,
        });

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
        Helpers.showSnackBar(context, empData[0].toString());
      }
    }
    if (empData.isEmpty && showError!) {
      Helpers.showSnackBar(
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
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double containerWidth = Helpers.minAndMax(deviceWidth * .9, 100, 1290);
    return HomeWithNavWrapper(
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
          Helpers.showSnackBar(context,
              "Please enter at least three characters to perform a search. 💉");
        }
      },
      headings: const [
        "Employee Details",
        "Vaccine",
        "Dose",
        "Due Date",
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
                                  final Map dosePendings = fullEmpData[index];
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
                                      [
                                        "Designation",
                                        ":",
                                        "${dosePendings['employee']['designation'] ?? 'Not Available'}"
                                      ]
                                    ],
                                    column2Texts: [
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
                                      "${dosePendings['dose_due_date'] ?? 'Not Available'}",
                                    ],
                                    onTap: () {
                                      Helpers.changeNavIndex(1, ref);
                                      context.go(
                                        "/record_vaccine_dose",
                                        extra: {
                                          ...dosePendings['employee']
                                              as Map<String, dynamic>,
                                          'vaccinations': [
                                            dosePendings['vaccination']
                                          ],
                                          'dose': dosePendings['dose'],
                                          'department': {
                                            'id': Random().nextInt(100),
                                            'name': (dosePendings['employee']
                                                    as Map<String, dynamic>)[
                                                'department']
                                          },
                                          'designation': {
                                            'id': Random().nextInt(100),
                                            'name': (dosePendings['employee']
                                                    as Map<String, dynamic>)[
                                                'designation']
                                          },
                                        },
                                      );
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
}

Widget buildCustomTextColumn(
    {required List<List<String>> columnTexts,
    required double width,
    double labelWidth = 80}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: columnTexts
        .map((items) => Row(
              children: items
                  .asMap() // Convert to iterable map
                  .entries
                  .map(
                    (entry) => SizedBox(
                      width: entry.key == 0
                          ? Helpers.minAndMax(width, 0, labelWidth)
                          : entry.key == 1
                              ? Helpers.minAndMax(width, 0, 50)
                              : Helpers.minAndMax(
                                  width, 0, 120), // Check if iteration is 2
                      child: CustomTextStyle(
                          text: entry.value,
                          fontSize: 14,
                          isBold: true,
                          color: Colors.black,
                          textAlign: entry.key == 1 ? TextAlign.center : null),
                    ),
                  )
                  .toList(),
            ))
        .toList(),
  );
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
