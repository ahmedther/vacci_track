# Generated by Django 4.2.7 on 2023-11-28 00:53

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0006_alter_employeevaccination_dose_date'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='employeevaccination',
            unique_together={('employee', 'vaccination', 'dose')},
        ),
    ]
