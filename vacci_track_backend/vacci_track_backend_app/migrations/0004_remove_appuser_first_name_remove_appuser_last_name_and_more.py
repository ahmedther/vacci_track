# Generated by Django 4.2.7 on 2023-11-10 23:48

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('vacci_track_backend_app', '0003_appuser_first_name_appuser_last_name_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='appuser',
            name='first_name',
        ),
        migrations.RemoveField(
            model_name='appuser',
            name='last_name',
        ),
        migrations.RemoveField(
            model_name='appuser',
            name='middle_name',
        ),
    ]