import typing as T

from django.core.exceptions import ValidationError
from django.db import models
from django.utils.translation import ugettext as _


def parse_gearset_spec(value: str) -> T.Set[int]:
    lines = [i.strip() for i in value.split()]
    gearset = set()
    for i in lines:
        r = i.split("-")
        if len(r) == 1:
            gearset.add(int(r[0]))
        elif len(r) == 2:
            gearset.update(range(int(r[0]), int(r[1]) + 1))
        else:
            raise ValueError(f"Invalid gear spec line: {i}")
    assert not any(i <= 0 for i in gearset)
    return gearset


def validate_gearset_spec(value: str):
    try:
        parse_gearset_spec(value)
    except:
        raise ValidationError(_("Invalid format!"))


class GearSet(models.Model):
    name = models.CharField(max_length=255)
    spec = models.TextField(
        max_length=1024,
        help_text=_(
            _(
                'Enter all gear-sets separated by space.\nYou can also use a "-" to specify range.'
            )
        ),
        validators=[validate_gearset_spec],
    )

    def __str__(self):
        return self.name

    def get_kv(self) -> T.Tuple[int, T.List[float]]:
        v = list(self.get_set())
        v.sort()
        k = hash(tuple(v))
        return k, v

    def get_set(self) -> T.Set[int]:
        return parse_gearset_spec(self.spec)
