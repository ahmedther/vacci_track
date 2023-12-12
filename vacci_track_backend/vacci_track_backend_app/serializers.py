from rest_framework import serializers
from vacci_track_backend_app.models import (
    Department,
    Designation,
    Facility,
    Employee,
    Vaccination,
    Dose,
    EmployeeVaccinationRecord,
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


class VaccinationSerializer(serializers.ModelSerializer):
    dose_count = serializers.SerializerMethodField()

    class Meta:
        model = Vaccination
        fields = ["id", "name", "total_number_of_doses", "other_notes", "dose_count"]

    def get_dose_count(self, obj: Vaccination):
        return obj.dose.count()


class DoseSerializer(serializers.ModelSerializer):
    vaccination = VaccinationSerializer()
    is_dose_due = serializers.SerializerMethodField()
    dose_due_date = serializers.SerializerMethodField()

    class Meta:
        model = Dose
        fields = (
            "id",
            "name",
            "dose_number",
            "gap_before_next_dose",
            "detail",
            "vaccination",
            "is_dose_due",
            "dose_due_date",
        )

    def get_is_dose_due(self, obj):
        emp_id = self.context.get("emp_id")
        if emp_id.isdigit():
            query = self.context.get("query")
            employee_vaccination_record = EmployeeVaccinationRecord.objects.filter(
                employee_id=emp_id,
                vaccination_id=query,
                dose=obj,
            ).first()
            if employee_vaccination_record:
                return employee_vaccination_record.is_dose_due
        return None

    def get_dose_due_date(self, obj):
        emp_id = self.context.get("emp_id")
        if emp_id.isdigit():
            query = self.context.get("query")
            employee_vaccination_record = EmployeeVaccinationRecord.objects.filter(
                employee_id=emp_id,
                vaccination_id=query,
                dose=obj,
            ).first()
            if employee_vaccination_record:
                return employee_vaccination_record.dose_due_date
        return None


class EmployeeSerializer(serializers.ModelSerializer):
    department = DepartmentSerializer()
    designation = DesignationSerializer()
    facility = FacilitySerializer()
    vaccinations = VaccinationSerializer(many=True)

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
            "uhid",
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
            "vaccinations",
        )


class EmpVaccFilterSerializer(serializers.ModelSerializer):
    department = DepartmentSerializer()
    designation = DesignationSerializer()
    vaccinations = serializers.SerializerMethodField()

    class Meta:
        model = Employee
        fields = (
            "id",
            "prefix",
            "gender",
            "first_name",
            "middle_name",
            "last_name",
            "uhid",
            "pr_number",
            "department",
            "designation",
            "vaccinations",
        )

    def get_vaccinations(self, obj: Employee):
        # Exclude vaccinations where dose_date is null
        vaccinations = obj.vaccinations.filter(
            employee_vaccination__dose_date__isnull=True,
            employee_vaccination__employee__id=obj.id,
        ).distinct()
        return VaccinationSerializer(vaccinations, many=True).data
