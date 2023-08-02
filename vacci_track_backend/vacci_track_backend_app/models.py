from django.db import models
from django.utils import timezone


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
        return self.name


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
    prefix = models.CharField(max_length=5, blank=True, null=True, db_index=True)
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
    phone_number = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    email_address = models.EmailField(blank=True, null=True, db_index=True)
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
    vaccinations = models.ManyToManyField(
        Vaccination, through="EmployeeVaccination", db_index=True, blank=True
    )

    def __str__(self):
        return (
            f"{self.prefix + ' ' if self.prefix else ''}"
            f"{self.first_name}"
            f" {' '.join(filter(None, [self.middle_name, self.last_name]))}"
            f" {'(' + self.department.name + ')' if self.department else ''}"
            f" {'-' + self.designation.name if self.designation else ''}"
        )


class EmployeeVaccination(models.Model):
    employee = models.ForeignKey(
        Employee,
        on_delete=models.PROTECT,
        blank=False,
        null=False,
        db_index=True,
        related_name="employee_vaccinations",
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
    dose_date = models.DateField(blank=False, null=False, db_index=True)
    dose_administered_by_name = models.CharField(
        max_length=255, blank=True, null=True, db_index=True
    )
    dose_administered_by_pr_number = models.CharField(
        max_length=20, blank=True, null=True, db_index=True
    )
    next_dose_due_date = models.DateField(blank=True, null=True, db_index=True)
    notes_remarks = models.TextField(blank=True, null=True, db_index=True)

    def save(self, *args, **kwargs):
        if self.dose_date is None or not isinstance(self.dose_date, timezone.datetime):
            self.dose_date = timezone.now()
        if self.dose.gap_before_next_dose != 0:
            self.next_dose_due_date = self.dose_date + timezone.timedelta(
                days=self.dose.gap_before_next_dose * 30
            )
        else:
            self.next_dose_due_date = None
        super().save(*args, **kwargs)

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
