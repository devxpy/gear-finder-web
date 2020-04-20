# Gear finder

<image width="400" src="https://user-images.githubusercontent.com/19492893/79752997-d26a3280-8332-11ea-95c7-0e6146486699.png" />

<image width="400" src="https://user-images.githubusercontent.com/19492893/79753622-d77bb180-8333-11ea-803c-c1f889ad59e1.png" />


This project is a rewrite of some [legacy software](https://gear-finder.software.informer.com/) used by mechanical workshops, 
to figure out the 4 gears that can be combined to obtain a particular gear ratio.

---

This process is quite computationally intensive. 

Python (even with numpy) consumes a few minutes to perform this task.

Therefore, we make use of [Cython](https://cython.org/) to create a C-extension for Python.
This let's us achieve near C-speeds, while still being able to use Python lanague features.

The result is a [fast compute core](https://github.com/devxpy/gear-finder-web/blob/master/gear_finder/compute.pyx), 
that the Django web app can call.

---

The naive algorithm iterates over all permutations (nPr) of the gear-set and filters out the ones that satisfy the required tolerance.

An optimization to the brute force permutation algorithm, can be done. 

[This optimization](https://github.com/devxpy/gear-finder-web/blob/e382e768f5e2fe0845b7bca8026f65cd5d36cab5/gear_finder/compute.pyx#L54) 
effectively reduces the problem space in half,
by explioting the commutative property of multiplication, i.e. -

`a/b x c/d = c/b x a/d`

---

The optimized Cython code also generates [HTML output directly](https://github.com/devxpy/gear-finder-web/blob/e382e768f5e2fe0845b7bca8026f65cd5d36cab5/gear_finder/compute.pyx#L121).

---

A password-protected admin panel is also provided that let's users define a gear set's range of values.

![image](https://user-images.githubusercontent.com/19492893/79753933-5cff6180-8334-11ea-9965-3320f9adebef.png)
