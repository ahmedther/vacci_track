# Generated by Django 4.2.7 on 2023-11-11 00:10

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0004_remove_appuser_first_name_remove_appuser_last_name_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='appuser',
            name='pr_number',
            field=models.CharField(db_index=True, max_length=16),
        ),
    ]
