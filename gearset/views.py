from datetime import datetime

from django.http import HttpResponse
from django.views.generic import FormView

from gear_finder.compute import compute
from gearset.forms import GearFinderForm


class GearFinderFormView(FormView):
    template_name = "gearset/gear_finder_form.html"
    form_class = GearFinderForm

    def form_valid(self, form):
        gset = form.cleaned_data["gear_set"]
        csv = compute(
            gset.name,
            gset.get_set(),
            form.cleaned_data["target"],
            form.cleaned_data["tolerance"],
        )
        response = HttpResponse(csv, content_type="application/csv")
        response[
            "Content-Disposition"
        ] = f'attachment; filename="Gear Finder {datetime.now().strftime("%d-%m-%Y_%I-%M_%p")} ({gset.name}).csv"'
        return response
