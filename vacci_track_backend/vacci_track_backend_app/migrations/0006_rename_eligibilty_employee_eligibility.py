# Generated by Django 4.2.2 on 2023-07-10 06:33

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0005_alter_employee_prefix'),
    ]

    operations = [
        migrations.RenameField(
            model_name='employee',
            old_name='eligibilty',
            new_name='eligibility',
        ),
    ]
