# Generated by Django 4.2.2 on 2023-07-08 08:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0004_alter_employee_joining_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employee',
            name='prefix',
            field=models.CharField(blank=True, db_index=True, max_length=5, null=True),
        ),
    ]
