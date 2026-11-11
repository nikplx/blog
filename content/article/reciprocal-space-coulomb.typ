#import "/typ/templates/blog.typ": *
#import "/typ/packages/physica.typ": *

#show: main.with(
  title: "Reciprocal Space Coulomb",
  desc: [],
  date: "2026-11-10",
  tags: (
    blog-tags.electronic-structure,
    blog-tags.tensor-decomposition,
  ),
)

= Calculating Coulomb Interactions

== What is the Coulomb force?

Coulombs force law tells us that for two charges $1$ and $2$ their electrostatic force is determined by 

$ 
abs(bold(F)) = (q_1 q_2)/norm(bold(r)_1 - bold(r)_2)^2
$

where $R$ is the distance. This function is singular at $R=0$ and is non-local. This means that we will need all possible combinations of spatial points (if we were to discretize $bold(r)$ using a grid). Also as was shown in a previous post, in 3D space the sum of contributions one charge experiences from interating with its neighbors diverges with $R$. We therefore can not cleanly truncate the Coulomb interaction as the tail of the sum (if we keep adding interactions with new "shells" around our reference charge) is the dominant part.

A possible way to isolate this divergence is by evaluating the Coulomb interaction in *reciprocal space*. For this we consider the potential (i.e. the line integral of the force) 
$
v(bold(r)) = -integral_infinity^r 1/r'^2 dif r'  = 1/bold(r)
$

we now use Poissons equation relating a electrostatic potential to the charge density it is created which for a unit charge takes the form

$
- laplacian v(bold(r)) = 4 pi delta(bold(r)).
$

This formula tells us that the presence of unit charges modelled by delta functions leads to a potential that is the superposition of their constituent potentials. 

#figure(image("/public/images/reciprocal-space-coulomb/coulomb_potential.png"))

Now *if we assume $v(bold(r))$ to be periodic*, we can express the Poisson equation in reciprocal space 

$
-laplacian sum_G v_G e^(i G dot r) = -4 pi sum_G e^(i G dot r).
$

We can see that the potential becomes just a function $v_G$ times our Fourier transfored Dirac delta function. 