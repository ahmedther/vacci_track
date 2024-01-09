from django import forms
from django.contrib.auth.forms import UserCreationForm


class NewUserCreationForm(UserCreationForm):
    # make fields required if desired
    first_name = forms.CharField(required=True)
    last_name = forms.CharField(required=True)

    class Meta(UserCreationForm.Meta):
        fields = ("username", "first_name", "last_name")
