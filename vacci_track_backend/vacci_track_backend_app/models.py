from django.contrib.auth.models import User
from django.db import models
from datetime import date
from django.db.models.signals import m2m_changed
from django.dispatch import receiver


class AppUser(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    GENDER_CHOICES = (
        ("Male", "Male"),
        ("Female", "Female"),
    )
    pr_number = models.CharField(max_length=16, blank=False, null=False, db_index=True)
    gender = models.CharField(
        max_length=10, choices=GENDER_CHOICES, blank=False, null=False, db_index=True
    )

    def __str__(self):
        return self.user.first_name + " " + self.user.last_name


class Department(models.Model):
    name = models.CharField(max_length=255, blank=False, null=False, db_index=True)
    department_hod = models.OneToOneField(
        "Employee",
        on_delete=models.SET_NULL,
        related_name="departments",
        db_index=True,
        null=True,
        blank=True,
    )

    def __str__(self):
        department_name = self.name
        hod_name = "Unknown"

        if self.department_hod:
            hod = self.department_hod
            hod_name = f"{getattr(hod, 'first_name', '')} {getattr(hod, 'middle_name', '')} {getattr(hod, 'last_name', '')}"

        return f"{department_name} and HOD: {hod_name}"


class Designation(models.Model):
    name = models.CharField(max_length=255, null=False, blank=False, db_index=True)

    def __str__(self):
        return self.name


class Facility(models.Model):
    name = models.CharField(max_length=255, null=False, blank=False, db_index=True)
    facility_id = models.CharField(max_length=8, null=False, blank=False, db_index=True)

    def __str__(self):
        return f"{self.name} - {self.facility_id}"


class Dose(models.Model):
    name = models.CharField(max_length=255, null=False, blank=False, db_index=True)
    dose_number = models.PositiveIntegerField(blank=False, null=False, db_index=True)
    gap_before_next_dose = models.PositiveIntegerField(
        blank=False,
        null=False,
        db_index=True,
        help_text="Gap Before Next Dose is Due. In Months ",
    )
    detail = models.TextField(blank=True, null=True, db_index=True)

    vaccination = models.ForeignKey(
        "Vaccination", on_delete=models.CASCADE, related_name="dose", db_index=True
    )

    def __str__(self):
        return f"{self.name} Assigned to {self.vaccination.name}."


class Vaccination(models.Model):
    name = models.CharField(max_length=255, null=False, blank=False, db_index=True)
    total_number_of_doses = models.PositiveIntegerField(
        blank=False, null=False, db_index=True
    )

    other_notes = models.TextField(blank=True, null=True, db_index=True)

    def __str__(self):
        return self.name


class Employee(models.Model):
    GENDER_CHOICES = (
        ("Male", "Male"),
        ("Female", "Female"),
    )
    ELIGIBILTY_CHOICES = (
        ("Eligible", "Eligible"),
        ("Non - Eligible", "Non - Eligible"),
    )
    prefix = models.CharField(max_length=10, blank=True, null=True, db_index=True)
    gender = models.CharField(
        max_length=10, choices=GENDER_CHOICES, blank=False, null=False, db_index=True
    )
    first_name = models.CharField(
        max_length=255, blank=False, null=False, db_index=True
    )
    middle_name = models.CharField(max_length=255, blank=True, null=True, db_index=True)
    last_name = models.CharField(max_length=255, blank=True, null=True, db_index=True)
    joining_date = models.DateField(blank=True, null=True, db_index=True)
    pr_number = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    uhid = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    email_id = models.EmailField(blank=True, null=True, db_index=True)
    department = models.ForeignKey(
        Department,
        on_delete=models.PROTECT,
        blank=True,
        null=True,
        related_name="employee",
        db_index=True,
    )
    designation = models.ForeignKey(
        Designation,
        on_delete=models.PROTECT,
        blank=True,
        null=True,
        related_name="employee",
        db_index=True,
    )
    facility = models.ForeignKey(
        Facility,
        on_delete=models.PROTECT,
        blank=True,
        null=True,
        related_name="employee",
        db_index=True,
    )
    status = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    eligibility = models.CharField(
        max_length=20,
        choices=ELIGIBILTY_CHOICES,
        blank=False,
        null=False,
        db_index=True,
    )
    added_by = models.ForeignKey(
        "auth.User",
        on_delete=models.PROTECT,
        db_index=True,
        null=False,
        blank=False,
        related_name="employee",
    )
    added_date = models.DateTimeField(
        auto_now_add=True,
        db_index=True,
        blank=False,
        null=False,
    )
    notes_remarks = models.TextField(blank=True, null=True, db_index=True)
    vaccinations = models.ManyToManyField(Vaccination, db_index=True, blank=True)

    def __str__(self):
        return (
            f"{self.prefix + ' ' if self.prefix else ''}"
            f"{self.first_name}"
            f" {' '.join(filter(None, [self.middle_name, self.last_name]))}"
            f" {'(' + self.department.name + ')' if self.department else ''}"
            f" {'- ' + self.designation.name if self.designation else ''}"
        )


class EmployeeVaccinationRecord(models.Model):
    employee = models.ForeignKey(
        Employee,
        on_delete=models.PROTECT,
        blank=False,
        null=False,
        db_index=True,
        related_name="employee_vaccination",
    )
    vaccination = models.ForeignKey(
        Vaccination,
        on_delete=models.PROTECT,
        blank=False,
        null=False,
        db_index=True,
        related_name="employee_vaccination",
    )
    dose = models.ForeignKey(
        Dose,
        on_delete=models.PROTECT,
        blank=False,
        null=False,
        db_index=True,
        related_name="employee_vaccination",
    )
    dose_date = models.DateField(blank=True, null=True, db_index=True)
    dose_administered_by_name = models.CharField(
        max_length=255, blank=True, null=True, db_index=True
    )
    dose_administered_by_pr_number = models.CharField(
        max_length=20, blank=True, null=True, db_index=True
    )
    dose_due_date = models.DateField(
        blank=True, null=True, db_index=True, verbose_name="Dose Due Date"
    )
    is_dose_due = models.BooleanField(
        default=False, db_index=True, verbose_name="Is This Dose Due?"
    )
    is_completed = models.BooleanField(
        default=False, db_index=True, verbose_name="Is All The Dose Completed?"
    )

    notes_remarks = models.TextField(blank=True, null=True, db_index=True)

    # def save(self, *args, **kwargs):
    #     if self.dose_date is None or not isinstance(self.dose_date, timezone.datetime):
    #         self.dose_date = timezone.now()
    #     if self.dose.gap_before_next_dose != 0:
    #         self.next_dose_due_date = self.dose_date + timezone.timedelta(
    #             days=self.dose.gap_before_next_dose * 30
    #         )
    #     else:
    #         self.next_dose_due_date = None
    #     super().save(*args, **kwargs)

    @receiver(m2m_changed, sender=Employee.vaccinations.through)
    def update_employee_vaccination_record(sender, instance, action, **kwargs):
        vaccinations = kwargs.get("pk_set")
        if action == "post_add":
            vaccinations_qs = Vaccination.objects.filter(pk__in=vaccinations)
            doses_qs = Dose.objects.filter(vaccination__in=vaccinations_qs).order_by(
                "vaccination__name", "dose_number"
            )
            records = [
                EmployeeVaccinationRecord(
                    employee=instance,
                    vaccination=dose.vaccination,
                    dose=dose,
                    is_dose_due=dose.dose_number == 1,
                    dose_due_date=date.today() if dose.dose_number == 1 else None,
                )
                for dose in doses_qs
            ]
            EmployeeVaccinationRecord.objects.bulk_create(records)
        elif action == "post_remove":
            EmployeeVaccinationRecord.objects.filter(
                employee=instance, vaccination_id__in=vaccinations
            ).delete()

    def __str__(self):
        return (
            f"{self.employee.prefix + ' ' if self.employee.prefix else ''}"
            f"{self.employee.first_name}"
            f" {' '.join(filter(None, [self.employee.middle_name, self.employee.last_name]))}"
            f" - "
            f" {self.vaccination.name if self.vaccination.name else ''}"
            f" {' - ' + self.dose.name if self.dose else ''}"
            f" {' - ' + str(self.dose_date) if self.dose_date else ''}"
        )

    class Meta:
        unique_together = (
            "employee",
            "vaccination",
            "dose",
        )
