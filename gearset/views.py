from datetime import datetime

from django.shortcuts import render
from django.utils.safestring import mark_safe
from django.views.generic import FormView

from gear_finder.compute import compute
from gearset.forms import GearFinderForm
from gearset.models import GearSet


class GearFinderFormView(FormView):
    template_name = "gear_finder_form.html"
    form_class = GearFinderForm

    def form_valid(self, form):
        target: float = form.cleaned_data["target"]
        tolerance: float = form.cleaned_data["tolerance"]
        gset: GearSet = form.cleaned_data["gear_set"]

        k, v = gset.get_kv()
        count, html_table = compute(k, v, target, tolerance)

        return render(
            self.request,
            "result.html",
            dict(
                result_table=mark_safe(html_table),
                count=count,
                target=target,
                tolerance=tolerance,
                gear_set_name=gset,
                gear_set_values=", ".join(map(str, v)),
                time=datetime.now(),
            ),
        )
