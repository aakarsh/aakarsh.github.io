---
layout: post
title: Linear Programming A Brief Introduction.
category:  algorithms
published: false
---

Many common optimization problems can be reduced to instances of
linear programming. Generaly speaking Linear programming problems are
problems where given a linear set of inequaities \\(Ax \leq b\\) we
must try to maximize a certain objective function \\(c^{T}x \\) while
\\( x \geq 0 \\). As illustrated below we set of equations \\(|I|\\)
representing contraining inequalities while \\(|E|\\) equations
represent equality constraints. The objective function thus acts as a
hyperplane in \\(R^n\\) and the inequalities specify a convex
polytope. Finding the value of \\(c^Tx\\) thus fixes the plane giving
us the maximum value of the objective function which still lies within
the polytope. Such a maxima lies on a vertex of the polytope. Thus
fiding the maximal value corresponds to finding which vertex of
polytope will be the last to touch a moving hyper-plane described by
the objective function.



$$ \text{ max } c_1 x_1 + c_2 x_2 + c_3 x_3 + \cdots + c_n x_n $$

$$ a_{i1} x_1 + a_{i2} x_2 + \cdots + a_{in} x_n \leq b_i  \text{ for } i \in I $$

$$ a_{i1} x_1 + a_{i2} x_2 + \cdots + a_{in} x_n  = b_i   \text{ for } i \in E $$

$$ x_i \geq 0  \text{ for } j \in N $$


For any defined maximizing set of linear inequalities there exists a
corresponding dual , linear program.

$$ \text{ min } b_1 y_1 + b_2 y_2 + \cdots + b_m y_m $$

$$ a_{1j} y_1 + a_{2j} y_2 + \cdots + a_{nj} y_m \leq c_j  \text{ for } j \in N $$
$$ a_{1j} y_1 + a_{2j} y_2 + \cdots + a_{nj} y_m  = c_j  \text{ for } j \notin N $$

$$ y_i \ geq 0 $$


---
[vazarani-lp]:[https://people.cs.berkeley.edu/~vazirani/algorithms/chap7.pdf]
[wiki-lp]:[https://en.wikipedia.org/wiki/Linear_programming]
