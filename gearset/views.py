from datetime import datetime

from django.shortcuts import render
from django.utils.safestring import mark_safe
from django.views.generic import FormView

from gear_finder.compute import compute
from gearset.forms import GearFinderForm


class GearFinderFormView(FormView):
    template_name = "gear_finder_form.html"
    form_class = GearFinderForm

    def form_valid(self, form):
        gset = form.cleaned_data["gear_set"]
        gset_values = gset.get_set()
        target = form.cleaned_data["target"]
        tolerance = form.cleaned_data["tolerance"]

        return render(
            self.request,
            "result.html",
            dict(
                result_table=mark_safe(compute(gset_values, target, tolerance)),
                target=target,
                tolerance=tolerance,
                gear_set_name=gset,
                gear_set_values=", ".join(map(str, gset_values)),
                time=datetime.now(),
            ),
        )
