from gear_finder.compute import compute
from gearset.models import GearSet

for gset in GearSet.objects.all():
    gset.get_set()
