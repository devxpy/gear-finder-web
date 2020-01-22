from django.apps import AppConfig


class GearsetConfig(AppConfig):
    name = 'gearset'

    def ready(self):
        from gear_finder import settings

        if settings.DEBUG:
            return

        from .models import GearSet
        from gear_finder.compute import build_cache

        print('Building gearset cache...')
        n = GearSet.objects.count()

        for i, gset in enumerate(GearSet.objects.all()):
            print(f'[{i + 1}/{n}] {gset!r}')
            build_cache(*gset.get_kv())

        print('Done!')
