from django.urls import path

from gearset.views import GearFinderFormView

urlpatterns = [path("", GearFinderFormView.as_view())]
