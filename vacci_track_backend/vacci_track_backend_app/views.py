import json
from vacci_track_backend_app.models import Department, Designation, Facility
from vacci_track_backend_app.sqlalchemy_con import SqlAlchemyConnection
from vacci_track_backend_app.serializers import (
    DepartmentSerializer,
    DesignationSerializer,
    FacilitySerializer,
    EmployeeSerializer,
)
from vacci_track_backend_app.models import Employee
from vacci_track_backend_app.helper import Helper
from django.shortcuts import render
from django.middleware import csrf
from django.http import JsonResponse
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
    alchemy = SqlAlchemyConnection()
    genders = alchemy.get_distict_prefix()
    genders = [{"gender": row[0]} for row in genders if row[0]]
    return Response(genders, status=200)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def searh_emp_on_oracle_db(request):
    pr_num = request.query_params["query"].split("=")[-1]
    try:
        alchemy = SqlAlchemyConnection()
        emp_data = alchemy.get_employees_details_with_pr_num(pr_num)
        if not emp_data:
            return Response(
                [{"error": f"No Records found for the User with PR Number {pr_num}"}],
                status=405,
            )
        converted_data = [
            {
                "prefix": tup[0],
                "first_name": tup[1],
                "middle_name": tup[2],
                "last_name": tup[3],
                "gender": "Male" if tup[4] == "M" else "Female",
                "phone_number": tup[6]
                if tup[5] == "" or tup[5] == None or len(tup[5]) < 2
                else tup[5],
                "email_id": tup[7],
                "facility": tup[8],
            }
            for tup in emp_data
        ]
        return Response(converted_data, status=200)
    except Exception as e:
        return Response([{"error": f"Erros has Occurred. Error :  {e}"}], status=405)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def search_employee(request):
    try:
        emp_data = Employee.objects.get(
            pr_number=request.query_params["query"].split("=")[-1]
        )
        serializer = EmployeeSerializer(emp_data)

        return Response([serializer.data], status=200)
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
        pr_number_exists = Employee.objects.filter(pr_number=data["pr_number"]).exists()

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
        print(data)
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
