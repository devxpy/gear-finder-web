import io
from collections import Iterable
import typing as T
import cython

import numpy as np
cimport numpy as np
from scipy.special import comb


ctypedef np.int_t INT_T
ctypedef np.float_t FLOAT_T
ctypedef np.uint8_t BOOL_T

cdef str TABLE_HEADER = "".join(
    f"<th>{i}</th>" for i in [
        "a", "b", "c", "d", "Ratio<br>(r = a/b x c/d)", "Deviation<br>(d = t - r)"
    ]
)

cdef dict CACHE = {}


cdef class Filtered:
    cdef long[:, :] combinations
    cdef double[:] ratios
    cdef double[:] diffs


def compute(long key, list gset, double target, double tolerance):
    cdef Filtered f
    cdef np.ndarray[INT_T, ndim=2] c
    cdef np.ndarray[FLOAT_T, ndim=2] r

    if key not in CACHE:
        build_cache(key, gset)
    c, r = CACHE[key]

    f = filter(c, r, target, tolerance)
    return len(f.ratios), to_html(f)


def build_cache(long key, list gset):
    cdef np.ndarray[INT_T] gset_arr
    cdef np.ndarray[INT_T, ndim=2] c
    cdef np.ndarray[FLOAT_T, ndim=2] r

    gset_arr = np.array(gset, dtype=np.int)
    c = combinations(gset_arr)
    r = ratios(c)
    CACHE[key] = c, r


cdef np.ndarray[INT_T, ndim=2] combinations(long[:] gset):
    cdef int i, j, k
    cdef long[:, :] two_pairs, four_pairs

    two_pairs = np.empty([int(comb(len(gset), 2)), 2], dtype=np.int)
    four_pairs = np.empty([int(comb(len(two_pairs), 2)), 4], dtype=np.int)

    with nogil, cython.boundscheck(False):
        k = 0
        for i in range(len(gset) - 1):
            for j in range(i + 1, len(gset)):
                two_pairs[k, 0] = gset[i]
                two_pairs[k, 1] = gset[j]
                k += 1

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


cdef Filtered filter(
    np.ndarray[INT_T, ndim=2] combinations,
    np.ndarray[FLOAT_T, ndim=2] ratios,
    double target,
    double tolerance,
):
    cdef np.ndarray[FLOAT_T] diff1, diff2, diffs
    cdef np.ndarray[BOOL_T, cast=True] filter1, filter2
    cdef np.ndarray[INT_T] sort_order
    cdef Filtered result

    diff1 = np.absolute(ratios[0] - target)
    diff2 = np.absolute(ratios[1] - target)

    filter1 = diff1 <= tolerance
    filter2 = diff2 <= tolerance

    diffs = np.concatenate([diff1[filter1], diff2[filter2]])
    sort_order = np.argsort(diffs)

    result = Filtered()
    result.diffs = diffs[sort_order]
    result.ratios = np.concatenate([ratios[0][filter1], ratios[1][filter2]])[sort_order]
    result.combinations = np.concatenate(
        [
            combinations[filter1][:, [0, 2, 1, 3]],
            combinations[filter2][:, [2, 0, 3, 1]]
        ]
    )[sort_order]

    return result


cdef str to_html(Filtered filtered):
    cdef int i
    cdef double r, d
    cdef long[:] c

    f = io.StringIO()
    f.write("<table><thead><tr>")
    f.write(TABLE_HEADER)
    f.write("</tr></thead><tbody>")

    for i in range(len(filtered.ratios)):
        c = filtered.combinations[i]
        r = filtered.ratios[i]
        d = filtered.diffs[i]

        f.write(
            f"<tr><td>{c[0]}</td><td>{c[1]}</td><td>{c[2]}</td><td>{c[3]}</td><td>{r}</td><td>{d}</td></tr>"
        )

    f.write("</tbody></table>")

    f.seek(0)
    return f.read()
