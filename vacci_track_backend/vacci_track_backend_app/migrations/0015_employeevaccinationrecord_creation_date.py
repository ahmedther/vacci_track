# Generated by Django 5.0.1 on 2024-01-05 05:58

import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0014_remove_employeevaccinationrecord_next_dose_due_date_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='employeevaccinationrecord',
            name='creation_date',
            field=models.DateTimeField(auto_now_add=True, db_index=True, default=django.utils.timezone.now),
            preserve_default=False,
        ),
    ]