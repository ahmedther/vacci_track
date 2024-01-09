import 'package:vacci_track_frontend/page/add_department_page.dart';
import 'package:vacci_track_frontend/page/add_designation_page.dart';
import 'package:vacci_track_frontend/page/add_dose_page.dart';
import 'package:vacci_track_frontend/page/add_facility_page.dart';
import 'package:vacci_track_frontend/page/add_new_employee_page.dart';
import 'package:vacci_track_frontend/page/add_vaccine_page.dart';
import 'package:vacci_track_frontend/page/home_page.dart';
import 'package:vacci_track_frontend/page/reports_download_page.dart';

const Map<int, String> homeRoutes = {
  0: HomePage.routeName,
  1: HomePage.routeName1,
  2: HomePage.routeName2,
  3: DownloadReportsPage.routeName,
};

const Map<int, String> navRoutes = {
  0: HomePage.routeName,
  1: AddNewEmployee.routeName,
  2: AddNewEmployee.routeName2,
  3: AddDesignation.routeName,
  4: AddDepartment.routeName,
  5: AddFacilityPage.routeName,
  6: AddVaccinePage.routeName,
  7: AddDosePage.routeName,
};
