from rest_framework import serializers
from vacci_track_backend_app.models import (
    Department,
    Designation,
    Facility,
    Employee,
    Vaccination,
    Dose,
)


class DepartmentSerializer(serializers.ModelSerializer):
    department_hod = serializers.SerializerMethodField()

    def get_department_hod(self, department):
        hod_employee = department.department_hod
        if hod_employee:
            return EmployeeSerializer(hod_employee).data
        return None

    class Meta:
        model = Department
        fields = ["id", "name", "department_hod"]


class DesignationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Designation
        fields = ["id", "name"]


class FacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = Facility
        fields = ["id", "name", "facility_id"]


class EmployeeSerializer(serializers.ModelSerializer):
    department = DepartmentSerializer()
    designation = DesignationSerializer()
    facility = FacilitySerializer()

    class Meta:
        model = Employee
        fields = (
            "id",
            "prefix",
            "gender",
            "first_name",
            "middle_name",
            "last_name",
            "joining_date",
            "pr_number",
            "phone_number",
            "email_id",
            "department",
            "designation",
            "facility",
            "status",
            "eligibility",
            "added_by",
            "added_date",
            "notes_remarks",
        )


class VaccinationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vaccination
        fields = "__all__"


class DoseSerializer(serializers.ModelSerializer):
    vaccination = VaccinationSerializer()

    class Meta:
        model = Dose
        fields = "__all__"
