# Generated by Django 4.2.7 on 2023-12-08 22:06

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0011_alter_employee_vaccinations'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='vaccinations',
            field=models.ManyToManyField(blank=True, db_index=True, to='vacci_track_backend_app.vaccination'),
        ),
        migrations.AlterField(
            model_name='employeevaccinationrecord',
            name='employee',
            field=models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='employee_vaccination', to='vacci_track_backend_app.employee'),
        ),
    ]
