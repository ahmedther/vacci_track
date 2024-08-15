# Generated by Django 5.0.1 on 2024-01-09 21:21

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Department',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(db_index=True, max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Designation',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(db_index=True, max_length=255)),
            ],
        ),
        migrations.CreateModel(
            name='Facility',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(db_index=True, max_length=255)),
                ('facility_id', models.CharField(db_index=True, max_length=8)),
            ],
        ),
        migrations.CreateModel(
            name='Vaccination',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(db_index=True, max_length=255)),
                ('total_number_of_doses', models.PositiveIntegerField(db_index=True)),
                ('other_notes', models.TextField(blank=True, db_index=True, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='AppUser',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('pr_number', models.CharField(db_index=True, max_length=16)),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], db_index=True, max_length=10)),
                ('user', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Employee',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('prefix', models.CharField(blank=True, db_index=True, max_length=10, null=True)),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], db_index=True, max_length=10)),
                ('first_name', models.CharField(db_index=True, max_length=255)),
                ('middle_name', models.CharField(blank=True, db_index=True, max_length=255, null=True)),
                ('last_name', models.CharField(blank=True, db_index=True, max_length=255, null=True)),
                ('joining_date', models.DateField(blank=True, db_index=True, null=True)),
                ('pr_number', models.CharField(blank=True, db_index=True, max_length=20, null=True)),
                ('uhid', models.CharField(blank=True, db_index=True, max_length=20, null=True)),
                ('phone_number', models.CharField(blank=True, db_index=True, max_length=20, null=True)),
                ('email_id', models.EmailField(blank=True, db_index=True, max_length=254, null=True)),
                ('status', models.CharField(blank=True, db_index=True, max_length=20, null=True)),
                ('eligibility', models.CharField(blank=True, choices=[('Eligible', 'Eligible'), ('Non - Eligible', 'Non - Eligible')], db_index=True, max_length=20, null=True)),
                ('added_date', models.DateTimeField(auto_now_add=True, db_index=True)),
                ('notes_remarks', models.TextField(blank=True, db_index=True, null=True)),
                ('added_by', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='employee', to=settings.AUTH_USER_MODEL)),
                ('department', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='employee', to='vacci_track_backend_app.department')),
                ('designation', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='employee', to='vacci_track_backend_app.designation')),
                ('facility', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.PROTECT, related_name='employee', to='vacci_track_backend_app.facility')),
                ('vaccinations', models.ManyToManyField(blank=True, db_index=True, to='vacci_track_backend_app.vaccination')),
            ],
        ),
        migrations.AddField(
            model_name='department',
            name='department_hod',
            field=models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='departments', to='vacci_track_backend_app.employee'),
        ),
        migrations.CreateModel(
            name='Dose',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(db_index=True, max_length=255)),
                ('dose_number', models.PositiveIntegerField(db_index=True)),
                ('gap_before_next_dose', models.PositiveIntegerField(db_index=True, help_text='Gap Before Next Dose is Due. In Months ')),
                ('detail', models.TextField(blank=True, db_index=True, null=True)),
                ('vaccination', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='dose', to='vacci_track_backend_app.vaccination')),
            ],
        ),
        migrations.CreateModel(
            name='EmployeeVaccinationRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('dose_date', models.DateField(blank=True, db_index=True, null=True)),
                ('dose_administered_by_name', models.CharField(blank=True, db_index=True, max_length=255, null=True)),
                ('dose_administered_by_pr_number', models.CharField(blank=True, db_index=True, max_length=20, null=True)),
                ('dose_due_date', models.DateField(blank=True, db_index=True, null=True, verbose_name='Dose Due Date')),
                ('is_dose_due', models.BooleanField(db_index=True, default=False, verbose_name='Is This Dose Due?')),
                ('is_completed', models.BooleanField(db_index=True, default=False, verbose_name='Is All The Dose Completed?')),
                ('creation_date', models.DateField(auto_now_add=True, db_index=True)),
                ('notes_remarks', models.TextField(blank=True, db_index=True, null=True)),
                ('dose', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='employee_vaccination', to='vacci_track_backend_app.dose')),
                ('employee', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='employee_vaccination', to='vacci_track_backend_app.employee')),
                ('vaccination', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='employee_vaccination', to='vacci_track_backend_app.vaccination')),
            ],
            options={
                'unique_together': {('employee', 'vaccination', 'dose')},
            },
        ),
    ]