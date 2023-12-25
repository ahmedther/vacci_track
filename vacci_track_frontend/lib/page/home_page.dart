// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vacci_track_frontend/components/text_style.dart';
import 'package:vacci_track_frontend/data/home_navigation_data.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/page/nav_wrapper.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';
import 'package:vacci_track_frontend/ui/full_screen_error.dart';
import 'package:vacci_track_frontend/ui/spinner.dart';
import 'package:vacci_track_frontend/ui/search_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/0';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final String headingText = "Home";
  bool isSpinning = true;
  bool isfetching = false;
  List fullEmpData = [];
  int page = 1;

  late final List<NavigationDestination> homeNavigationList =
      getHomNavigationDestination(uiColor);

  Future<List> getEmployeesData({String? query}) async {
    final API_URL = await Helpers.load_env();
    final List empData = await Helpers.makeGetRequest(
        "http://$API_URL/api/get_vaccine_records/",
        query: {
          "due_date_filter": "True",
          "page": page.toString(),
          "query": query,
        });

    return empData;
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

    if (mounted) {
      setState(() {
        isSpinning = false;
        isfetching = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      print("ponki");

      await getEmpData();
    });

    scrollController.addListener(() {
      print("ss");
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
    final themeColor =
        Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);
    double containerWidth = Helpers.minAndMax(deviceWidth * .9, 100, 1290);

    return NavWrapper(
      child: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(deviceHeight * .02),
              child: Text(
                headingText,
                style: TextStyle(
                  fontSize: deviceHeight * .03,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 30, right: 20, bottom: deviceHeight * .02),
              width: containerWidth * 0.99,
              child: NavigationBar(
                onDestinationSelected: (int value) {
                  print(value);
                },
                indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                animationDuration: const Duration(seconds: 3),
                backgroundColor: themeColor,
                selectedIndex: 0,
                elevation: 10,
                shadowColor: Colors.black,
                surfaceTintColor: Colors.white,
                destinations: homeNavigationList,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 30, right: 20, bottom: deviceHeight * .02),
              child: CustomSearchBar(
                deviceWidth: deviceWidth,
                onPressed: () async {
                  if (searchController.text.trim().length > 2) {
                    setState(() {
                      isSpinning = true;
                    });
                    await getEmpData(
                        query: searchController.text.trim(), showError: true);
                  } else {
                    Helpers.showSnackBar(context,
                        "Please enter at least three characters to perform a search. 💉");
                  }
                },
                controller: searchController,
                uiColor: uiColor,
                backgroundColor: themeColor,
                hintText: "Search For Employees With Name or UHID/PR Number",
                onChanged: (String value) async {
                  if (value.trim().length > 3 || value.trim() == '') {
                    await getEmpData(query: value);
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 30, right: 20),
              width: containerWidth,
              child: Card(
                color: themeColor,
                surfaceTintColor: Colors.white,
                child: ListTile(
                  hoverColor: const Color.fromARGB(31, 0, 0, 0),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (containerWidth > 592) ...{
                        SizedBox(
                          width: containerWidth > 1238
                              ? containerWidth * 0.54
                              : null,
                          child: Row(
                            children: [
                              SizedBox(
                                width: containerWidth > 1234
                                    ? 618.5
                                    : containerWidth > 801
                                        ? 302
                                        : Helpers.minAndMax(
                                            containerWidth * .2, 130, 160),
                                child: CustomTextStyle(
                                    text: "Employee Details",
                                    fontSize: 14,
                                    isBold: true,
                                    color: uiColor,
                                    textAlign: TextAlign.center),
                              ),
                              buildVerticalDivider(
                                  deviceHeight: deviceHeight,
                                  deviceWidth: deviceWidth,
                                  uiColor: uiColor),
                            ],
                          ),
                        ),
                      } else ...{
                        const SizedBox(width: 45),
                      },
                      ...buildColumnBox(
                          text: [
                            "Vaccine",
                            "Dose",
                            "Due Date",
                          ],
                          width: containerWidth * .1,
                          deviceHeight: deviceHeight,
                          deviceWidth: deviceWidth,
                          uiColor: uiColor,
                          useTextwithUiColor: true),
                    ],
                  ),
                ),
              ),
            ),
            isSpinning
                ? SpinnerWithOverlay(
                    spinnerColor: uiColor,
                  )
                : Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 30, right: 20),
                      width: containerWidth,
                      child: fullEmpData.isNotEmpty
                          ? ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: fullEmpData.length + 1,
                              itemBuilder: (context, index) {
                                if (index < fullEmpData.length) {
                                  Map dosePendings = fullEmpData[index];
                                  // print(dosePendings);
                                  return Card(
                                    color: themeColor,
                                    surfaceTintColor: Colors.white,
                                    child: ListTile(
                                      hoverColor:
                                          const Color.fromARGB(31, 0, 0, 0),
                                      onTap: () async {},
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Helpers.getRandomColor(),
                                        child: dosePendings['employee']
                                                    ['first_name'] !=
                                                null
                                            ? CustomTextStyle(
                                                text: dosePendings['employee']
                                                    ['first_name'][0],
                                                color: Colors.white,
                                                fontSize: 24,
                                                isBold: true,
                                              )
                                            : const FaIcon(
                                                FontAwesomeIcons.userAlt,
                                                color: Colors.white),
                                      ),
                                      title: CustomTextStyle(
                                        text:
                                            '${dosePendings['employee']['prefix'] ?? ""} ${dosePendings['employee']['first_name'] ?? ""} ${dosePendings['employee']['middle_name'] ?? ""} ${dosePendings['employee']['last_name'] ?? ""}',
                                        color: uiColor,
                                        isBold: true,
                                      ),
                                      subtitle: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (containerWidth > 801) ...{
                                            SizedBox(
                                              width: containerWidth > 1234
                                                  ? containerWidth * 0.5
                                                  : null,
                                              child: Row(
                                                children: [
                                                  buildCustomTextColumn(
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
                                                      width: deviceWidth * .2),
                                                  buildVerticalDivider(
                                                      deviceHeight:
                                                          deviceHeight,
                                                      deviceWidth: deviceWidth,
                                                      uiColor: uiColor),
                                                  if (containerWidth >
                                                      1234) ...{
                                                    buildCustomTextColumn(
                                                        column1Texts: [
                                                          [
                                                            "Phone Number",
                                                            ":",
                                                            "${dosePendings['employee']['gender'] ?? 'Not Available'}"
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
                                                        width: deviceWidth * .2,
                                                        labelWidth: 97),
                                                    buildVerticalDivider(
                                                        deviceHeight:
                                                            deviceHeight,
                                                        deviceWidth:
                                                            deviceWidth,
                                                        uiColor: uiColor),
                                                  }
                                                ],
                                              ),
                                            )
                                          } else if (containerWidth > 592) ...{
                                            buildCustomTextColumn(
                                                column1Texts: [
                                                  [
                                                    "${dosePendings['employee']['gender'] ?? ''}"
                                                  ],
                                                  [
                                                    "5100${dosePendings['employee']['pr_number'] ?? 'Not Available'}"
                                                  ],
                                                  [
                                                    "${dosePendings['employee']['designation'] ?? 'Not Available'}"
                                                  ]
                                                ],
                                                width: deviceWidth * .2),
                                            buildVerticalDivider(
                                                deviceHeight: deviceHeight,
                                                deviceWidth: deviceWidth,
                                                uiColor: uiColor),
                                          },
                                          ...buildColumnBox(
                                              text: [
                                                "${dosePendings['vaccination']['name'] ?? 'Not Available'}",
                                                "${dosePendings['dose']['name'] ?? 'Not Available'}",
                                                "${dosePendings['dose_due_date'] ?? 'Not Available'}",
                                              ],
                                              width: containerWidth * .1,
                                              deviceHeight: deviceHeight,
                                              deviceWidth: deviceWidth,
                                              uiColor: uiColor),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return SpinnerWithOverlay(
                                    spinnerColor: uiColor,
                                    message: "Loading Page $page ...",
                                  );
                                }
                              },
                            )
                          : CustomErrorWidget(uiColor: uiColor),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

Widget buildCustomTextColumn(
    {required List<List<String>> column1Texts,
    required double width,
    double labelWidth = 80}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: column1Texts
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

Widget buildVerticalDivider(
    {required double deviceWidth,
    required double deviceHeight,
    required Color uiColor}) {
  return SizedBox(
    height: Helpers.minAndMax(deviceHeight * .05, 0, 50),
    width: Helpers.minAndMax(deviceWidth * .1, 0, 50),
    child: VerticalDivider(
      color: uiColor,
      thickness: 1,
    ),
  );
}

List<Widget> buildColumnBox({
  required List<String> text,
  required double width,
  required double deviceHeight,
  required double deviceWidth,
  required Color uiColor,
  bool useTextwithUiColor = false,
}) {
  return text
      .asMap()
      .entries
      .map((entry) {
        int idx = entry.key;
        String e = entry.value;
        return [
          SizedBox(
            width: width,
            child: CustomTextStyle(
              text: e,
              fontSize: 14,
              isBold: true,
              color: useTextwithUiColor ? uiColor : Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
          if (idx != text.length - 1)
            buildVerticalDivider(
              deviceHeight: deviceHeight,
              deviceWidth: deviceWidth,
              uiColor: uiColor,
            ),
        ];
      })
      .expand((x) => x)
      .toList();
}
