# Generated by Django 4.2.7 on 2023-11-30 17:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0010_alter_employeevaccinationrecord_dose_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='vaccinations',
            field=models.ManyToManyField(blank=True, db_index=True, related_name='employees', to='vacci_track_backend_app.vaccination'),
        ),
    ]
