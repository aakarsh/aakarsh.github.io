---
layout: post
title: Some notes on introduction to group theory 
category: posts
published: false
---

Some notes on group theory. Proof sketches, interesting
theorems. Possible future directions.The reference book for this will
be I.J Herstein's Abstract Algebra : Theory and Practice

* Groups
  * Definition of a Group
    * `Group:` A non empty set of elements `G` is said to form a `group`
      if in `G` there is a defined `binary operation` called `product`
      and denoted by `.` such that
        * `closure` :  \\( a,b \in G \\) implies that \\( a.b \in G \\)
        * `associative`: \\( a,b,c \in G \\) implies that \\( a.(b.c) = (a.b).c \\)
        * `identity`: \\( \exists e \in G \\)  such that   \\( a.e = e.a = a \\) \\( \forall a \in G \\)
        * `inverse` : \\(\forall a \in G \\) we have \\( \exists a^{-1} \in G \\) such that \\( a.a^{-1} = e \\)
        
    * `Abelian(Commutative) Group` : A `group G` such that \\( \forall a,b \in G\\) we have \\( a.b = b.a \\)

  * Some Examples of Groups
    * Ex : Let `G` be integers let `.` be `+` then we have a group
      with `e` as `0` and \\(a^{-1} = -a\\)
    
  * Preliminary Lemmas
    * `Lemma` If `G` is a group then
      * The identity element of `G` is unique
      * Every \\( a \in G \\) , \\( a^{-1})^{-1} = a \\)
      * For every \\( a,b \in G \\) we have \\( (a.b)^{-1} = b^{-1}. a^{-1} \\)      
  * Subgroups
    * A on non-empty `subset H `of group `G` is a subgroup of `G`  if and only if
      * \\(a,b \in H \\) implies that \\( ab \in H \\)
      * \\(a \in H \\) implies that \\( a^{-1} \in H \\)
      
  * A Counting Principle
  * Normal Subgroups and Quotient Groups
  * Homomorphisms
  * Automorphisms
  * Cayley's Theorem
  * Permutation Groups
  * Another Counting Principle
  * Sylow's Theorem
  * Direct Products
  * Finite Abelian Groups

* Ring Theory
  * Definition and Examples of Rings
  * Some Special Class of Rings
  * Homomorphism
  * Ideals and Quotient Rings
  * The Field and Quotients of an Integral Domain
  * Euclidean Rings
  * A Particular Euclidean Ring
  * Polynomial Rings
  * Polynomials over the Rational Field
  * Polynomial Rings over Commutative Rings

* Vector Spaces and Modules
  * Elementary Basic Concepts
  * Linear Independence and Bases
  * Dual Spaces
  * Inner Product Spaces
  * Modules

* Fields
  * Extension Fields
  * The Trancendence of `e`
  * Roots of Polynomials
  * Construction with Straightedge and Compass
  * More About Roots
  * The Elements of Galois theory
  * Solvability of Radicals
  * Galois Groups over the Rationals

* Linear Tranformations
  * The algebra of linear transformations
  * Characteristic Roots
  * Matrices
  * Canonical Forms: Triangular Form
  * Canonical Forms: Nilpotent Transformations
  * Canonical Forms: A Decomposition of `V`: Jordan Form
  * Canonical Forms: Rational Conanical Form
  * Trace and Transpose
  * Determinants
  * Hermitian Unitary, and Normal Transformations
  * Real Quadratic Forms
  
* Selected Topics
  * Finite Fields
  * Wedderburn's Theorem on Finite Deivision Rigns
  * Theorem of Frobenius
  * Itegral Quarternions and Four Square Theorem



--- 
[herstein]: http://abstract.ups.edu/download/aata-20110810.pdf

