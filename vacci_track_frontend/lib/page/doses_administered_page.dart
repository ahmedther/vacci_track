import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vacci_track_frontend/components/home_nav_wrapper.dart';
import 'package:vacci_track_frontend/helpers/helper_functions.dart';
import 'package:vacci_track_frontend/provider/nav_state_provider.dart';

class DosesAdministeredPage extends ConsumerStatefulWidget {
  static const String routeName = '/doses_recently_administered';

  const DosesAdministeredPage({super.key});

  @override
  ConsumerState<DosesAdministeredPage> createState() =>
      _DosesAdministeredPageState();
}

class _DosesAdministeredPageState extends ConsumerState<DosesAdministeredPage> {
  late final Color backgroundColor = ref.watch(navProvider).backgroundColor!;
  late final Color uiColor = ref.watch(navProvider).uiColor!;
  late final Color themeColor =
      Helpers.getThemeColorWithUIColor(context: context, uiColor: uiColor);
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

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
      pageHeading: "Recent Vaccination Administered",
      themeColor: themeColor,
      uiColor: uiColor,
      backgroundColor: backgroundColor,
      searchController: searchController,
      searchHintText: "Search For Employees With Name or UHID/PR Number",
      headings: ["headin1"],
    );
  }
}
