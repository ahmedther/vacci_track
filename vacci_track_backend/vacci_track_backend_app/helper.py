from datetime import datetime
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from vacci_track_backend_app.models import *
from vacci_track_backend_app.excel_generator import excel_generator
from django.db.models import Q, F, Value, CharField
from django.db.models.functions import Concat


class Helper:
    def __init__(self):
        pass

    def get_validated_date(self, date):
        if date is not None:
            try:
                date_only = date[:10]  # Extract the first 10 characters (YYYY-MM-DD)
                validated_date = datetime.strptime(date_only, "%Y-%m-%d").date()
            except:
                validated_date = None
        else:
            validated_date = None
        return validated_date

    def edit_user(self, data: dict):
        AppUser.objects.filter(user__pk=data.get("id")).update(
            gender=data.get("gender").capitalize()
        )

    def save_employee(self, request, data: dict):
        validated_join_date = self.get_validated_date(data.get("joining_date"))

        defaults = {
            "prefix": data.get("prefix"),
            "gender": data["gender"],
            "first_name": data["first_name"],
            "middle_name": data.get("middle_name"),
            "last_name": data.get("last_name"),
            "joining_date": validated_join_date,
            "uhid": data.get("uhid"),
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
        employee.vaccinations.set(data.get("vaccinations"))

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

    def save_vaccine(self, data: dict):
        faci_id = data.get("id")
        data.pop("edit", None)
        data.pop("id", None)

        if not faci_id:
            existing_vaccine = Vaccination.objects.filter(name=data["name"])

            if existing_vaccine:
                return None, None

        vaccine, created = Vaccination.objects.update_or_create(
            id=faci_id, defaults=data
        )
        return vaccine, created

    def save_dose(self, data: dict):
        dose_id = data.pop("id", None)
        data.pop("edit", None)

        vaccination = Vaccination.objects.filter(pk=data.get("vaccination")).first()
        if not vaccination:
            raise ValueError("Invalid vaccination ID.")

        data["vaccination"] = vaccination

        if not dose_id:
            existing_dose = Dose.objects.filter(
                name=data["name"], vaccination=vaccination
            ).first()
            if existing_dose:
                return None, existing_dose

        if dose_id or vaccination.dose.count() < vaccination.total_number_of_doses:
            dose, created = Dose.objects.update_or_create(id=dose_id, defaults=data)
            return dose, created

        raise ValueError(
            "The total number of doses for this vaccination has been reached."
        )

    def save_employee_vaccination(self, data: dict):
        data["dose_date"] = self.get_validated_date(data.get("dose_date"))
        next_dose_due_date = (
            datetime.strptime(data["next_dose_due_date"], "%d-%b-%Y")
            if data["next_dose_due_date"] is not None
            else None
        )
        data.pop("next_dose_due_date", None)
        dose, created = EmployeeVaccinationRecord.objects.update_or_create(
            employee_id=data["employee_id"],
            vaccination_id=data["vaccination_id"],
            dose_id=data["dose_id"],
            defaults=data,
        )

        record = (
            EmployeeVaccinationRecord.objects.filter(
                employee_id=data["employee_id"],
                vaccination_id=data["vaccination_id"],
                dose_date__isnull=True,
            )
            .order_by("dose")
            .first()
        )

        if record:
            record.dose_due_date = next_dose_due_date
            record.save()

        return dose, created

    def paginator(self, page, object, records_per_page=20):
        paginator = Paginator(object, records_per_page)
        if not page:
            page = 1
        try:
            results = paginator.page(page)
        except PageNotAnInteger:
            page = 1
            results = paginator.page(page)
        except EmptyPage:
            page = paginator.num_pages
            results = paginator.page(page)

        return results, paginator.num_pages

    def get_emp_vac_rec(
        self,
        query: str,
        emp_id: str,
        due_date_filter: bool = True,
        dose_date_filter: bool = False,
        vacc_compl_filter: bool = False,
    ):
        order_by_fields = ["-id", "vaccination", "dose"]

        if due_date_filter:
            filters = Q(dose_due_date__lt=datetime.now().date()) & Q(dose_date=None)
            order_by_fields.insert(0, "-dose_due_date")

        if dose_date_filter:
            filters = ~Q(dose_date=None)
            order_by_fields.insert(0, "-dose_date")

        if vacc_compl_filter:
            filters = Q(is_completed=True)
            order_by_fields.insert(0, "-dose_date")

        if query:
            filters &= (
                Q(employee__first_name__icontains=query)
                | Q(employee__last_name__icontains=query)
                | Q(employee__pr_number=query)
                | Q(employee__uhid=query)
            )
        if emp_id:
            filters = Q(employee__id=emp_id)
            order_by_fields = ["vaccination", "dose", "-dose_date"]

        emp_rec = EmployeeVaccinationRecord.objects.filter(filters).order_by(
            *order_by_fields
        )

        return emp_rec

    def generate_excel(self, data: dict):
        print(data)
        from_date = self.get_validated_date(data["from_date"])
        to_date = self.get_validated_date(data["to_date"])
        filter_data = data.get("filter", "all")
        query: str = data.get("query")

        filters = Q(creation_date__range=(from_date, to_date))
        order_by_fields = ["creation_date", "employee", "vaccination", "dose"]

        if filter_data == "due_date_filter":
            filters = Q(dose_due_date__range=(from_date, to_date)) & Q(dose_date=None)
            order_by_fields[0] = "dose_due_date"

        if filter_data == "dose_date_filter":
            filters = Q(dose_date__range=(from_date, to_date))
            order_by_fields[0] = "dose_date"

        if query:
            filters &= (
                Q(employee__first_name__icontains=query)
                | Q(employee__last_name__icontains=query)
                | Q(employee__pr_number=query)
                | Q(employee__uhid=query)
                | Q(vaccination__name__icontains=query)
                | Q(dose__name__icontains=query)
            )

        emp_rec = (
            EmployeeVaccinationRecord.objects.filter(filters)
            .select_related(
                "employee__department",
                "employee__designation",
                "employee__facility",
                "vaccination",
                "dose",
            )
            .order_by(*order_by_fields)
            .values_list(
                "id",
                Concat(
                    F("employee__prefix"),
                    Value(" "),
                    F("employee__first_name"),
                    Value(" "),
                    F("employee__middle_name"),
                    Value(" "),
                    F("employee__last_name"),
                    output_field=CharField(),
                ),
                F("vaccination__name"),
                F("dose__name"),
                F("dose_due_date"),
                F("dose_date"),
                F("dose_administered_by_name"),
                F("dose_administered_by_pr_number"),
                F("creation_date"),
                F("employee__gender"),
                F("employee__pr_number"),
                F("employee__uhid"),
                F("employee__phone_number"),
                F("employee__email_id"),
                F("employee__department__name"),
                F("employee__designation__name"),
                F("employee__facility__name"),
                F("employee__joining_date"),
                Concat(
                    F("notes_remarks"),
                    Value("\n\n"),
                    F("employee__notes_remarks"),
                    output_field=CharField(),
                ),
                named=True,
            )
        )
        column = [
            "Record Number",
            "Employee",
            "Vaccination",
            "Dose",
            "Dose Due Date",
            "Administered Date",
            "Administrer Name",
            "Administrer PR",
            "Created Date",
            "Gender",
            "PR Number",
            "UHID",
            "Phone Number",
            "Email ID",
            "Departmnet",
            "Designation",
            "Facility",
            "Joining Date",
            "Notes / Remarks",
        ]
        page_name = (
            "Vaccinaion Records"
            if filter_data == "all"
            else filter_data + "_with_" + query.replace(" ", "_")
            if query
            else ""
        )
        excel_file_path = excel_generator(
            column=column,
            data=emp_rec,
            page_name=page_name,
        )
        return excel_file_path, page_name

        # emp_rec = (
        #     EmployeeVaccinationRecord.objects.filter(filters)
        #     .order_by(*order_by_fields)
        #     .values()
        # )
        # column = [
        #     "Record Number",
        #     "Employee",
        #     "Vaccination",
        #     "Dose",
        #     "Dose Due Date",
        #     "Administered Date",
        #     "Administrer Name",
        #     "Administrer PR",
        #     "Created Date",
        #     "Gender",
        #     "PR Number",
        #     "UHID",
        #     "Phone Number",
        #     "Email ID",
        #     "Departmnet",
        #     "Designation",
        #     "Facility",
        #     "Joining Date",
        #     "Notes / Remarks",
        # ]
        # rec_data = []

        # for records in emp_rec:
        #     emp = Employee.objects.filter(id=records["employee_id"]).first()
        #     vac = Vaccination.objects.filter(id=records["vaccination_id"]).first()
        #     dose = Dose.objects.filter(id=records["dose_id"]).first()
        #     rec_data.append(
        #         [
        #             records["id"],
        #             " ".join(
        #                 filter(
        #                     None,
        #                     [
        #                         emp.prefix,
        #                         emp.first_name,
        #                         emp.middle_name,
        #                         emp.last_name,
        #                     ],
        #                 )
        #             ),
        #             vac.name if vac else "",
        #             dose.name if dose else "",
        #             records["dose_due_date"],
        #             records["dose_date"],
        #             records["dose_administered_by_name"],
        #             records["dose_administered_by_pr_number"],
        #             records["creation_date"],
        #             emp.gender,
        #             emp.pr_number,
        #             emp.uhid,
        #             emp.phone_number,
        #             emp.email_id,
        #             emp.department.name if emp.department else "",
        #             emp.designation.name if emp.designation else "",
        #             emp.facility.name if emp.facility else "",
        #             emp.joining_date,
        #             "\n\n".join(
        #                 filter(
        #                     None,
        #                     [
        #                         records["notes_remarks"],
        #                         emp.notes_remarks,
        #                     ],
        #                 )
        #             ),
        #         ],
        #     )

        # excel_file_path = excel_generator(
        #     column=column,
        #     data=rec_data,
        #     page_name="Vaccinaion Records" if filter_data == "all" else filter_data,
        # )
        # return excel_file_path
