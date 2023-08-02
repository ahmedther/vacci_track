from django.urls import path
from . import views


urlpatterns = [
    path("login/", views.login_user, name="login"),
    path("csrf_token/", views.get_csrf_token, name="get_csrf_token"),
    path("logout/", views.logout_user, name="logout_user"),
    path("check_login/", views.check_login, name="check_login"),
    path("get_department_list/", views.get_department_list, name="get_department_list"),
    path(
        "get_designation_list/", views.get_designation_list, name="get_designation_list"
    ),
    path("get_facility_list/", views.get_facility_list, name="get_facility_list"),
    path(
        "searh_emp_on_oracle_db/",
        views.searh_emp_on_oracle_db,
        name="searh_emp_on_oracle_db",
    ),
    path("get_prefix/", views.get_prefix, name="get_prefix"),
    path("create_new_employee/", views.create_new_employee, name="create_new_employee"),
    path("search_employee/", views.search_employee, name="search_employee"),
]
