# Generated by Django 5.0.1 on 2024-01-05 06:32

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0015_employeevaccinationrecord_creation_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='employeevaccinationrecord',
            name='creation_date',
            field=models.DateField(auto_now_add=True, db_index=True),
        ),
    ]
