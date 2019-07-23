from django.forms import forms, ModelChoiceField, FloatField

from gearset.models import GearSet


class GearFinderForm(forms.Form):
    gear_set = ModelChoiceField(GearSet.objects.all(), required=True, initial=-1)
    target = FloatField(label="Required Ratio")
    tolerance = FloatField(initial=0.00009)
