import json
import os

from django.shortcuts import render

from vacci_track_backend_app.models import (
    Department,
    Designation,
    Facility,
    Employee,
    Vaccination,
    Dose,
)
from vacci_track_backend_app.sqlalchemy_con import SqlAlchemyConnection
from vacci_track_backend_app.serializers import (
    DepartmentSerializer,
    DesignationSerializer,
    FacilitySerializer,
    EmployeeSerializer,
    VaccinationSerializer,
    DoseSerializer,
    EmpVaccFilterSerializer,
    EmployeeVaccinationRecordSerializer,
)
from vacci_track_backend_app.helper import Helper
from django.middleware import csrf
from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from django.contrib.auth import login, logout, authenticate
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from django.db.models import Q


@api_view(["POST"])
@permission_classes([AllowAny])
def login_user(request):
    try:
        data = json.loads(request.body)
        username = data.get("username")
        password = data.get("password")
        user = authenticate(
            request,
            username=username,
            password=password,
        )

        if user is None:
            return JsonResponse(
                {
                    "error": "Wrong User ID or Password. Try again or call 33333 / 33330 to reset it"
                },
                status=401,
            )
        login(request, user)
        token, _ = Token.objects.get_or_create(user=user)
        return JsonResponse(
            {
                "user_fullname": f"{request.user.get_full_name().title()}",
                "username": f"{user.get_username()}",
                "user_id": f"{user.id}",
                "gender": f"{user.appuser.gender}",
                "pr_number": f"{user.appuser.pr_number}",
                "token": token.key,
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse({"error": f"Error has occourced. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def logout_user(request):
    try:
        logout(request),
        return JsonResponse(
            {
                "success": True,
            },
            status=200,
        )
    except Exception as e:
        return JsonResponse({"error": f"Error has occourced. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def check_login(request):
    try:
        user = request.user
        token, _ = Token.objects.get_or_create(user=user)
        return JsonResponse(
            {
                "user_fullname": f"{request.user.get_full_name().title()}",
                "username": f"{user.get_username()}",
                "user_id": f"{user.id}",
                "token": token.key,
                "success": True,
            },
            status=200,
        )

    except Exception as e:
        return JsonResponse({"success": False}, status=405)


def get_csrf_token(request):
    csrf_token = csrf.get_token(request)
    return JsonResponse({"csrfToken": csrf_token})


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_department_list(request):
    departments = Department.objects.all()
    serializer = DepartmentSerializer(departments, many=True)
    return Response(serializer.data, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_designation_list(request):
    designation = Designation.objects.all()
    serializer = DesignationSerializer(designation, many=True)
    return Response(serializer.data, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_facility_list(request):
    facility = Facility.objects.all()
    serializer = FacilitySerializer(facility, many=True)
    return Response(serializer.data, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_prefix(request):
    try:
        alchemy = SqlAlchemyConnection()
        genders = alchemy.get_distict_prefix()
        genders = [{"gender": row[0]} for row in genders if row[0]]
    except:
        genders = [
            {"gender": "Ms"},
            {"gender": "Master"},
            {"gender": "Dr"},
            {"gender": "General"},
            {"gender": "Ms."},
            {"gender": "Dr."},
            {"gender": "Mr."},
            {"gender": "Mr"},
            {"gender": "Mrs."},
        ]
    return Response(genders, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_vaccination_list(request):
    vaccine = Vaccination.objects.all()
    serializer = VaccinationSerializer(vaccine, many=True)
    return Response(serializer.data, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def searh_emp_on_oracle_db(request):
    query = request.query_params["query"].split("=")[-1]
    try:
        alchemy = SqlAlchemyConnection()
        emp_data = alchemy.get_employees_details(query)
        if not emp_data:
            return Response(
                [{"error": f"No Records found for the User with PR Number {query}"}],
                status=405,
            )

        converted_data = [
            {
                "prefix": tup[0],
                "first_name": tup[1],
                "middle_name": tup[2],
                "last_name": tup[3],
                "uhid": tup[4],
                "pr_number": tup[5],
                "gender": "Male" if tup[6] == "M" else "Female",
                "phone_number": tup[7]
                if tup[8] == "" or tup[8] == None or len(tup[8]) < 2
                else tup[8],
                "email_id": tup[9],
                "facility": FacilitySerializer(
                    Facility.objects.filter(facility_id=tup[10]).first()
                ).data
                if Facility.objects.filter(facility_id=tup[10]).exists()
                else {"name": tup[10], "id": None},
            }
            for tup in emp_data
        ]

        return Response(converted_data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def edit_app_user(request):
    try:
        data: dict = json.loads(request.body)
        Helper().edit_user(data)
        return JsonResponse({"success": True}, status=200)

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_employee(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        emp_data = Employee.objects.filter(
            Q(pr_number=query) | Q(uhid__icontains=query)
        )
        serializer = EmployeeSerializer(emp_data, many=True)
        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_employee_by_name(request):
    try:
        query = request.query_params.get("query", "")

        if query == "":
            emp_data = (
                Employee.objects.filter(employee_vaccination__dose_date__isnull=True)
                .order_by("-id")
                .distinct()[:15]
            )
        else:
            emp_data = (
                Employee.objects.filter(
                    Q(employee_vaccination__dose_date__isnull=True)
                    & (
                        Q(pr_number__icontains=query)
                        | Q(uhid__icontains=query)
                        | Q(first_name__icontains=query)
                        | Q(middle_name__icontains=query)
                        | Q(last_name__icontains=query)
                    )
                )
                .order_by("-id")
                .distinct()[:15]
            )
        serializer = EmpVaccFilterSerializer(emp_data, many=True)
        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_hod(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        emp_data = Employee.objects.filter(
            Q(pr_number__icontains=query)
            | Q(first_name__icontains=query)
            | Q(middle_name__icontains=query)
            | Q(last_name__icontains=query)
        )
        if not emp_data:
            raise Exception(f"No Employee found with Search Query '{query}'")

        serializer = EmployeeSerializer(emp_data, many=True)
        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def create_new_employee(request):
    try:
        data: dict = json.loads(request.body)
        pr_number_exists = Employee.objects.filter(
            Q(uhid=data.get("uhid")) | Q(pr_number=data.get("pr_number"))
        ).exists()

        if pr_number_exists and not data.get("edit"):
            return JsonResponse(
                {"error": "User Already Exists. Try Editing this User"}, status=405
            )
        else:
            Helper().save_employee(request, data)
            return JsonResponse({"success": True}, status=200)

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_designation(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        designation = Designation.objects.filter(name__icontains=query)

        if not designation:
            raise Exception(f"No Designation found with Search Query '{query}'")

        serializer = DesignationSerializer(designation, many=True)
        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_designation(request):
    try:
        data: dict = json.loads(request.body)
        design, _ = Helper().save_designation(data)
        if design:
            return JsonResponse({"success": True}, status=200)
        else:
            return JsonResponse(
                {"error": "Designation Already Exists. Try Editing this Designation"},
                status=405,
            )

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_facility(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        facility = Facility.objects.filter(name__icontains=query)
        if not facility:
            raise Exception(f"No facility found with Search Query '{query}'")

        serializer = FacilitySerializer(facility, many=True)

        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_facility(request):
    try:
        data: dict = json.loads(request.body)
        design, _ = Helper().save_facility(data)
        if design:
            return JsonResponse({"success": True}, status=200)
        else:
            return JsonResponse(
                {"error": "Designation Already Exists. Try Editing this Designation"},
                status=405,
            )

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_department(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        department = Department.objects.filter(name__icontains=query)

        if not department:
            raise Exception(f"No Department found with Search Query '{query}'")

        serializer = DepartmentSerializer(department, many=True)

        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_department(request):
    try:
        data: dict = json.loads(request.body)
        dept, _ = Helper().save_department(data)
        if dept:
            return JsonResponse({"success": True}, status=200)
        else:
            return JsonResponse(
                {"error": "Department Already Exists. Try Editing this Department"},
                status=405,
            )

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_vaccine(request):
    try:
        query = request.query_params["query"].split("=")[-1]
        vaccine = Vaccination.objects.filter(name__icontains=query)

        if not vaccine:
            raise Exception(f"No Vaccination found with Search Query '{query}'")

        serializer = VaccinationSerializer(vaccine, many=True)

        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_vaccine(request):
    try:
        data: dict = json.loads(request.body)
        dept, _ = Helper().save_vaccine(data)
        if dept:
            return JsonResponse({"success": True}, status=200)
        else:
            return JsonResponse(
                {"error": "Vaccine Already Exists. Try Editing this Vaccine"},
                status=405,
            )

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_dose(request):
    try:
        data: dict = json.loads(request.body)
        dose, existing_dose = Helper().save_dose(data)
        if dose:
            return JsonResponse({"success": True}, status=200)
        else:
            return JsonResponse(
                {
                    "error": f"Dose {existing_dose.name} Already Assigned to {existing_dose.vaccination}"
                },
                status=405,
            )

    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_dose(request):
    try:
        query: str = request.query_params.get("query", "")
        emp_id: str = request.query_params.get("emp_id", "")
        dose = (
            Dose.objects.filter(
                employee_vaccination__employee=emp_id,
                employee_vaccination__vaccination=query,
                employee_vaccination__dose_date__isnull=True,
            ).order_by("dose_number")[:1]
            if query.isdigit()
            else Dose.objects.filter(name__icontains=query)
        )

        if not dose:
            raise Exception(f"No Dose found with Search Query '{query}'")

        serializer = DoseSerializer(
            dose, many=True, context={"emp_id": emp_id, "query": query}
        )
        return Response(serializer.data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def add_vaccination_data(request):
    try:
        data: dict = json.loads(request.body)
        dose, created = Helper().save_employee_vaccination(data)
        if created:
            return JsonResponse(
                {"error": f"This shouldn't happen. Report this error immediately"},
                status=405,
            )
        return JsonResponse({"success": True}, status=200)
    except Exception as e:
        return JsonResponse({"error": f"Error has occurred. Error: {e}"}, status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_vaccine_records(request):
    try:
        records_per_page = request.query_params.get("records_per_page", 20)
        due_date_filter = (
            True
            if request.query_params.get("due_date_filter", None) == "True"
            else False
        )
        dose_date_filter = (
            True
            if request.query_params.get("dose_date_filter", None) == "True"
            else False
        )
        vacc_compl_filter = (
            True
            if request.query_params.get("vacc_compl_filter", None) == "True"
            else False
        )
        page = request.query_params.get("page", "1")
        query = request.query_params.get("query", None)
        emp_id = request.query_params.get("emp_id", None)

        emp_vac_rec = Helper().get_emp_vac_rec(
            query, emp_id, due_date_filter, dose_date_filter, vacc_compl_filter
        )

        emp_vac_rec_page, paginator_num_pages = Helper().paginator(
            page, emp_vac_rec, records_per_page
        )

        serializer = EmployeeVaccinationRecordSerializer(emp_vac_rec_page, many=True)

        return Response([serializer.data, paginator_num_pages], status=200)

    except Exception as e:
        return Response(
            [[{"error": f"Error has Occurred. Error :  {e}"}], 0], status=405
        )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_report(request):
    try:
        excel_file_path, filename = Helper().generate_excel(request.query_params)
        response = HttpResponse(
            open(excel_file_path, "rb"),
            content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        )
        response["Content-Disposition"] = f"attachment; filename={filename}"
        response[
            "Access-Control-Expose-Headers"
        ] = "Content-Disposition"  # Add this for CORS
        return response
        # response = FileResponse(open(excel_file_path, "rb"))
    except Exception as e:
        return Response(
            [[{"error": f"Error has Occurred. Error :  {e}"}], 0], status=405
        )


def home(request):
    # from dotenv import load_dotenv
    # # # env_path = f"{Path(__file__).resolve().parent.parent.parent}/.env"
    # load_dotenv()

    context = {"SERVE_FLUTTER_ON": os.environ.get("SERVE_FLUTTER_ON")}
    return render(request, "vacci_track_backend_app/index.html", context)
