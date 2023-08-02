import datetime
from vacci_track_backend_app.models import *


class Helper:
    def __init__(self):
        pass

    def save_employee(self, request, data: dict):
        validated_join_date = self.get_validated_date(data.get("joining_date"))
        employee_data = {
            "prefix": data.get("prefix"),
            "gender": data["gender"],
            "first_name": data["first_name"],
            "middle_name": data.get("middle_name"),
            "last_name": data.get("last_name"),
            "joining_date": validated_join_date,
            "pr_number": data.get("pr_number"),
            "phone_number": data.get("phone_number"),
            "email_address": data.get("email_address"),
            "department": Department.objects.get(id=data.get("department"))
            if data.get("department")
            else None,
            "designation": Designation.objects.get(id=data.get("designation"))
            if data.get("designation")
            else None,
            "facility": Facility.objects.get(id=data.get("facility"))
            if data.get("facility")
            else None,
            "status": data.get("status"),
            "eligibility": data["eligibility"],
            "added_by": request.user,
            "notes_remarks": data.get("notes_remarks"),
        }

        Employee.objects.create(**employee_data)

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
