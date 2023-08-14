import datetime
from vacci_track_backend_app.models import *


class Helper:
    def __init__(self):
        pass

    def get_validated_date(self, date):
        if date is not None:
            try:
                date_only = date[:10]  # Extract the first 10 characters (YYYY-MM-DD)
                validated_date = datetime.datetime.strptime(
                    date_only, "%Y-%m-%d"
                ).date()
            except:
                validated_date = None
        else:
            validated_date = None
        return validated_date

    def save_employee(self, request, data: dict):
        validated_join_date = self.get_validated_date(data.get("joining_date"))

        defaults = {
            "prefix": data.get("prefix"),
            "gender": data["gender"],
            "first_name": data["first_name"],
            "middle_name": data.get("middle_name"),
            "last_name": data.get("last_name"),
            "joining_date": validated_join_date,
            "pr_number": data.get("pr_number"),
            "phone_number": data.get("phone_number"),
            "email_id": data.get("email_id"),
            "department_id": data.get("department"),
            "designation_id": data.get("designation"),
            "facility_id": data.get("facility"),
            "status": data.get("status"),
            "eligibility": data["eligibility"],
            "added_by": request.user,
            "notes_remarks": data.get("notes_remarks"),
        }

        employee, created = Employee.objects.update_or_create(
            pr_number=data.get("pr_number"), defaults=defaults
        )

    def save_designation(self, data: dict):
        desig_id = data.get("id")
        data.pop("edit", None)
        data.pop("id", None)
        existing_designation = Designation.objects.filter(name=data["name"])
        if existing_designation:
            return None, None

        designation, created = Designation.objects.update_or_create(
            id=desig_id, defaults=data
        )
        return designation, created

    def save_department(self, data: dict):
        desig_id = data.get("id")
        data.pop("edit", None)
        data.pop("id", None)

        if not desig_id:
            existing_department = Department.objects.filter(name=data["name"])
            if existing_department:
                return None, None

        data["department_hod"] = Employee.objects.filter(
            pk=data.get("department_hod")
        ).first()
        department, created = Department.objects.update_or_create(
            id=desig_id, defaults=data
        )
        return department, created

    def save_facility(self, data: dict):
        faci_id = data.get("id")
        data.pop("edit", None)
        data.pop("id", None)

        if not faci_id:
            existing_facility = Facility.objects.filter(name=data["name"])

            if existing_facility:
                return None, None

        facility, created = Facility.objects.update_or_create(id=faci_id, defaults=data)
        return facility, created
