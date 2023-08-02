from django.contrib import admin
from .models import (
    Department,
    Designation,
    Facility,
    Dose,
    Vaccination,
    Employee,
    EmployeeVaccination,
)


class DepartmentAdmin(admin.ModelAdmin):
    search_fields = ["name"]


class DesignationAdmin(admin.ModelAdmin):
    search_fields = ["name"]


class FacilityAdmin(admin.ModelAdmin):
    search_fields = ["name", "facility_id"]


class DoseAdmin(admin.ModelAdmin):
    search_fields = ["name", "vaccination__name__icontains"]


class VaccinationAdmin(admin.ModelAdmin):
    search_fields = ["name"]


class EmployeeVaccinationInline(admin.TabularInline):
    model = EmployeeVaccination
    extra = 1


class EmployeeAdmin(admin.ModelAdmin):
    search_fields = [
        "first_name",
        "middle_name",
        "last_name",
        "pr_number",
        "phone_number",
        "email_address",
    ]
    inlines = [EmployeeVaccinationInline]


class EmployeeVaccinationAdmin(admin.ModelAdmin):
    search_fields = [
        "employee__first_name",
        "employee__middle_name",
        "employee__last_name",
        "vaccination__name__icontains",
    ]


models_and_admins = [
    (Department, DepartmentAdmin),
    (Designation, DesignationAdmin),
    (Facility, FacilityAdmin),
    (Dose, DoseAdmin),
    (Vaccination, VaccinationAdmin),
    (Employee, EmployeeAdmin),
    (EmployeeVaccination, EmployeeVaccinationAdmin),
]


for model, admin_class in models_and_admins:
    admin.site.register(model, admin_class)


# CHnage admin Panel
admin.site.site_header = "Vacci Track Admin Panel"
admin.site.site_title = "Vacci Track Admin Panel"
admin.site.index_title = "Vacci Track Administration"
admin.site.enable_nav_sidebar = True
