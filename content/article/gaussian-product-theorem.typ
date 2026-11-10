#import "/typ/templates/blog.typ": *
#import "../../templates/env.typ": url-base
#import "/typ/packages/physica.typ": *

#show: main.with(
  title: "Gaussian Product Theorem",
  desc: [],
  date: "2026-11-09",
  tags: (
    blog-tags.electronic-structure,
  ),
)

= Gaussian Product Theorem

Given two Gaussian functions of the form
$
chi_A (x) = e^(-a (x -A)^2) \
chi_B (x) = e^(-b (x -B)^2) \
$

#v(2em)

$
chi_A (x) chi_B (x) &= e^(-a (x-A)^2 - b (x-B)^2) \
&= e^(-(a + b)x^2 + 2x (A a + B b) - A^2 a - B^2 b) \
$

For a given quadratic polynomial we can form
$
- alpha x^2 + 2 beta x = -alpha [x^2 - 2 beta/alpha x]
$ 

where we complete the square using the "adding zero trick"
$
- alpha x^2 + 2 beta x &= -alpha [x^2 - 2 beta/alpha x + gamma^2 - gamma^2] \
 &= -alpha [(x^2 - 2 beta/alpha x + gamma^2) - gamma^2] \
 &= -alpha [(x-gamma)^2 - gamma^2]
$
where
$
gamma = beta/alpha.
$

Going back to our exponential we set
$
alpha &= a + b \
beta &= A a + B b
$

and replace the first two terms with our formula to find

$
chi_A (x) chi_B (x) &=  exp(-(a+b)[(x - (A a + B b)/(a+b))^2 - ((A a + B b)/(a + b))^2] - A^2 a - B^2 b)\
&= exp(-(a+b)[(x - (A a + B b)/(a+b))^2 - ((A a + B b)/(a + b))^2 + (A^2 a)/(a+b) + (B^2 b)/(a+b)]) \
&= exp(-(a+b)[(x - (A a + B b)/(a+b))^2 - ((A a + B b)/(a + b))^2 + (A^2 a + B^2 b)/(a+b)]) \
&= exp(-(a+b)[(x - (A a + B b)/(a+b))^2]) times exp( -(a+b) [-((A a + B b)/(a + b))^2 + (A^2 a + B^2 b)/(a+b)]) \
$

we can simplify the constant term
$
 &-(a+b) [-((A a + B b)/(a + b))^2 + (A^2 a + B^2 b)/(a+b)] \
 &=-(a+b) [-(A a + B b)^2/(a + b)^2 + ((a+b)(A^2 a + B^2 b))/(a+b)^2]  \
 &=-(a+b) (-(A a + B b)^2 + ((a+b)(A^2 a + B^2 b)))/(a+b)^2  \
 &=-(a+b)^(-1) [-(A a + B b)^2 + (a+b)(A^2 a + B^2 b)] \
 &=-(a+b)^(-1) [-(A^2 a^2 + B^2 b^2 + 2 A B a b) + (A^2 a^2 + B^2 b^2 + B^2 b a + A^2 a b)] \
 &=-(a+b)^(-1) (-A^2 a^2 - B^2 b^2 - 2 A B a b + A^2 a^2 + B^2 b^2 + B^2 b a + A^2 a b) \
 &=-(a+b)^(-1) (cancel(-A^2 a^2) - cancel(B^2 b^2) - 2 A B a b + cancel(A^2 a^2) + cancel(B^2 b^2) + B^2 b a + A^2 a b) \
 &=-(a+b)^(-1) (A^2 a b - 2 A B a b + B^2 a b) \
 &=-(a+b)^(-1) (a b)(A^2 - 2 A B + B^2) \
 &=-((a b)/(a+b))(A - B)^2 \
 &=-mu (A - B)^2
$

where 

$
mu = (a b)/(a + b).
$


We therefore get
$
chi_A (x) chi_B (x) &= exp(-(a+b)[(x - (A a + B b)/(a+b))^2]) times exp(-mu (A - B)^2) \
chi_A (x) chi_B (x) &= e^(-mu (A - B)^2) dot e^(-(a+b)(x - gamma)^2) \
$

with 
$
gamma = (A a + B b)/(a+b)
$

which shows that our product is just another Gaussian function with a constant scaling factor, exponent $(a+b)$ and centered at $(A a + B b)/(a + b)$ i.e. on the line between the centers of the two input functions.
