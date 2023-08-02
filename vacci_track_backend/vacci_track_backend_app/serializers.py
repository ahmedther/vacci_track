from rest_framework import serializers
from vacci_track_backend_app.models import Department, Designation, Facility, Employee


class DepartmentSerializer(serializers.ModelSerializer):
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
            "prefix",
            "gender",
            "first_name",
            "middle_name",
            "last_name",
            "joining_date",
            "pr_number",
            "phone_number",
            "email_address",
            "department",
            "designation",
            "facility",
            "status",
            "eligibility",
            "added_by",
            "added_date",
            "notes_remarks",
        )
