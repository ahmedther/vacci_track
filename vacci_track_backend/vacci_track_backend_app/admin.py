from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import User
from vacci_track_backend_app.forms import NewUserCreationForm

from .models import (
    Department,
    Designation,
    Facility,
    Dose,
    Vaccination,
    Employee,
    EmployeeVaccination,
    AppUser,
)


class AppUserInline(admin.StackedInline):
    model = AppUser
    can_delete = False
    verbose_name_plural = "App Users"


class AppUserAdmin(BaseUserAdmin):
    add_form = NewUserCreationForm
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "username",
                    "password1",
                    "password2",
                    "first_name",
                    "last_name",
                ),
            },
        ),
    )
    inlines = (AppUserInline,)


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


admin.site.unregister(User)

models_and_admins = [
    (User, AppUserAdmin),
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
