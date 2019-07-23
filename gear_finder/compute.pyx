import io
import numpy as np
cimport numpy as np
from scipy.special import comb

ctypedef np.int_t INT_T
ctypedef np.float_t FLOAT_T
ctypedef np.uint8_t BOOL_T


cdef CSV_HEADER = """Target(t), {0}
Tolerance, {1}
Gear set name,{2}                
Gear set values,{3}                

a,b,c,d,Ratio (r = a/b x c/d),Deviation (d = t - r)
"""


cdef np.ndarray[INT_T, ndim=2] combinations(long[:] gset):
    cdef int i, j, k

    cdef long[:, :] two_pairs = np.empty([int(comb(len(gset), 2)), 2], dtype=np.int)
    k = 0
    for i in range(len(gset) - 1):
        for j in range(i + 1, len(gset)):
            two_pairs[k, 0] = gset[i]
            two_pairs[k, 1] = gset[j]
            k += 1

    cdef long [:, :] four_pairs = np.empty([int(comb(len(two_pairs), 2)), 4], dtype=np.int)
    k = 0
    for i in range(len(two_pairs) - 1):
        for j in range(i + 1, len(two_pairs)):
            four_pairs[k, :2] = two_pairs[i]
            four_pairs[k, 2:] = two_pairs[j]
            k += 1

    return np.asarray(four_pairs)


cdef np.ndarray[FLOAT_T, ndim=2] ratios(np.ndarray[INT_T, ndim=2] arr):
    return np.array(
        [
            (arr[:, 0] * arr[:, 1]) / (arr[:, 2] * arr[:, 3]),
            (arr[:, 2] * arr[:, 3]) / (arr[:, 0] * arr[:, 1])
        ]
    )


cdef np.ndarray[INT_T, ndim=2] filter(
    np.ndarray[INT_T, ndim=2] combinations,
    np.ndarray[FLOAT_T, ndim=2] ratios,
    double target,
    double tolerance,
):
    cdef np.ndarray[FLOAT_T, ndim=1] \
        diff1 = np.absolute(ratios[0] - target), \
        diff2 = np.absolute(ratios[1] - target)

    cdef np.ndarray[BOOL_T, ndim=1, cast=True] \
        mask1 = diff1 <= tolerance, \
        mask2 = diff2 <= tolerance

    cdef np.ndarray[INT_T, ndim=1] sort_order = np.argsort(np.concatenate([diff1[mask1], diff2[mask2]]))

    return np.concatenate(
        [combinations[mask1][:, [0, 2, 1, 3]], combinations[mask2][:,[ 2, 0, 3, 1]]]
    )[sort_order]

cdef str to_csv(
    str name,
    long[:] gset,
    double target,
    double tolerance,
    np.ndarray[INT_T, ndim=2] combinations
):
    cdef int i, j, r

    f = io.StringIO()

    header = CSV_HEADER.format(target, tolerance, name, ','.join(map(str, gset)))
    f.write(header)
    r = len(header.splitlines()) + 1

    for c in combinations:
        f.write(f"{','.join(map(str, c))},=A{r}/B{r}*C{r}/D{r},=ABS(B1-E{r})\n")
        r += 1

    f.seek(0)
    return f.read()

cdef cache = {}


def compute(str name, values, double target, double tolerance):
    cdef long[:] gset = np.array(sorted(values))

    key = hash(tuple(gset))
    try:
        c, r = cache[key]
    except KeyError:
        c = combinations(gset)
        r = ratios(c)
        cache[key] = c, r

    return to_csv(name, gset, target, tolerance, filter(c, r, target, tolerance))
