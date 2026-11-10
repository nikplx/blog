#import "/typ/templates/blog.typ": *
#import "../../templates/env.typ": url-base
#import "/typ/packages/physica.typ": *

#show: main.with(
  title: "Ewald Summation",
  desc: [],
  date: "2026-11-09",
  tags: (
    blog-tags.electronic-structure,
  ),
)

= How to evaluate infinite integrals

This article closely follows the recent review *Wavefunction-based periodic quantum chemistry* by Ye and Berkelbach (https://arxiv.org/abs/2607.28554).
I will explore some problems sketched in the paper in a bit more detail, especially ones that relate to the treatment of two-electron integrals. All pictures are created by Anthropic AI models using Matplotlib.

== Periodic Gaussian Type Orbitals
When treating chemical systems with periodic boundary conditions our particles do not only interact with their neighbors in the system but also with all their images in our neighbor cells including their own images. When considering the electron-electron pair interaction term in a Gaussian Type Orbital (GTO) basis, we place the atom-centered Gaussians on each Atom in our unit cell.


@translated-interaction shows an atom centered GTO $mu$ interacting with its neighbor $nu$ as well as its translated version $nu^(bold(T)_1)$. As we have to take into account *ALL* translations, the interacting terms in our Hamiltonian become infinite sums over all lattice translations $T$.

#figure(image("/public/images/ewald-summations/translated_interaction.png"), caption: [GTOs interacting in a system with periodic boundary conditions])<translated-interaction>

== What integrals do we even need?
In the Born-Oppenheimer Approximation the electronic structure problem is fully determined by the integrals (neglecting $E_(n n)$):
 
$
S_(b_1 b_2) &= integral_Omega dif r med Phi^*_b_1 (bold(r)) Phi_b_2 (bold(r)) \
T_(b_1 b_2) &= integral_Omega dif r med Phi^*_b_1 (bold(r)) [-1/2 laplacian] Phi_b_2 (bold(r)) \
V_(b_1 b_2) &= -sum_A Z_A integral_Omega dif r Phi^*_b_1 (bold(r)) nu_E (bold(r -R_A)) Phi_b_2 (bold(r)) \
(b_1 b_2|b_3 b_4) &= integral.double_Omega dif r_1 dif r_2 Phi^*_b_1 (bold(r_1)) Phi_b_2 (bold(r_1)) nu_E (bold(r_1 - r_2)) Phi^*_b_3 (bold(r_2)) Phi_b_4 (bold(r_2)) 
$

== Why do we need range separation?

 If we now want to evaluate our ERI integral, we find that it takes the form
$
(mu nu|lambda sigma) = sum_(bold(T_1 T_2 T_3)) (mu^0 nu^(bold(T)_1) | lambda^(bold(T)_2) sigma^(bold(T)_3)).
$

This says that basis function $mu$ (which is our reference point) builds a pair density with $nu$ (another Gaussian by the #link(url-base + "article/gaussian-product-theorem")[Gaussian Product Theorem]) and all images of $nu$ translated by $bold(T)_1$. Another pair-density is formed by $lambda$
and all images of $sigma$ translates by $bold(T)_3$. Our $rho_(mu nu)$ pair density now
interacts with our $rho_(lambda sigma)$ pair density and all its images we get by translating $rho_(lambda sigma)$ by $bold(T)_2$.  So there are *three infinite sums* over lattice translations involved.

@pair-interaction tries to visualize this, although the $bold(T)_1$ assumes $bold(T)$ is one dimensional (our cell repeats only into one direction i.e. forms an infinite line shaped supercell). 

#figure(image("/public/images/ewald-summations/pair_interaction.png"), caption: [Co-densities of basis functions $mu nu$ interacting with co-density $lambda sigma$ and all its images we get by translating with vector $bold(T)_1$.])<pair-interaction>

In general, infinite sums are pretty bad when we are trying to actually evaluate an integral, as we can not have an infinite summation on a finite computer. Therefore, we have to use properties of the interaction to make the summation finite.

Lets look at the interactions between the co-densities $|mu nu)$ and $|lambda sigma)$ first. By the #link(url-base+"article/gaussian-product-theorem")[Gaussian Product Theorem] we know that the product of two Gaussian functions of the form 
$
chi_A (x) = e^(-a (x - A)^2) \
chi_B (x) = e^(-b (x - B)^2)
$

is a again a Gaussian of the form
$
chi_A (x) chi_B (x) = e^(-mu (A-B)^2) e^(-(a+b)(x-gamma)^2).
$

Since $A$ and $B$ represent the center points of our Gaussians, we can see that the product of any Gaussian with another function in a different unit cell will pick up a pre-factor of 
$
e^(-mu |bold(T)|^2).
$

We therefore know that overlap lattice sums between two basis functions will decay exponentially the further we move move away (in terms of lattice translation) from our reference point. This is why these two sums converge fast.

A more difficult case is the summation over $bold(T)_2$, where both co-densities interact via the Coulomb interaction. To make sense of this interaction, we can imagine both co-densities as multipoles i.e. we just assume that seen from far aways they will behave just like point charges. For point-charges the classical Coulomb force law tells us that 

$
F = (q_1 q_2)/R
$

where $q$ denotes the charge of our multipoles and $R$ is their distance. In a 3D periodic lattice, if we add more "shells" of unit cells we add around our reference cell we build a kind of spherical supercell. As the volume of a sphere grows with $4/3 pi R^3$ we add about $R^2$ new cells with every step we add to $R$. As shown in @growing-spheres, this $R^2$ interaction strength we add with every shell unfortunately grows faster than the Coulomb force diminishes and therefore our sum grows with $R$ and diverges.

#figure(image("/public/images/ewald-summations/growing_spheres.png"), caption: [])<growing-spheres>

== Range Separation

Now that we established that we can not just use lattice summation, we must come up with another scheme. We can use a distance split in our Coulomb operator:

$
v(r) = v^"SR" (bold(r)) + v^"LR" (bold(r)) = ("erfc"(omega r))/r + "erf"(omega r)/r.
$


#figure(image("/public/images/ewald-summations/erfc.png"), caption: [])<erfc>


The $"erf"$ and $"erfc"$ functions derive from the integral of a Gaussian PDF. With these functions we can split a short from a long range contribution with the sum still representing our full coulomb operator. Going back to our two electron integral 

$
(b_1 b_2|b_3 b_4) &= integral.double_Omega dif r_1 dif r_2 Phi^*_b_1 (bold(r_1)) Phi_b_2 (bold(r_1)) times v (bold(r_1 - r_2)) times Phi^*_b_3 (bold(r_2)) Phi_b_4 (bold(r_2)) 
$

we can factor it into a SR and LR part
$
(mu nu|lambda sigma) = (mu nu|lambda sigma)^"SR" + (mu nu|lambda sigma)^"LR" - pi/(Omega omega^2) S_(mu nu) S_(lambda sigma)
$

where $Omega$ represents the cell volume and the last term is equivalent to the effective charges of our multipoles $q_1 q_2$. Where we can now evaluate the SR contribution by a lattice sum as it is guaranteed to converge
$
(mu nu|lambda sigma)^"SR" &= sum_(bold(T)_1 bold(T)_2 bold(T)_3) (mu^0 nu^(bold(T)_1)|lambda^(bold(T)_2) sigma^(bold(T)_3))\
(mu^0 nu^(bold(T)_1)|lambda^(bold(T)_2) sigma^(bold(T)_3))^"SR" &= integral.double dif^3 r_1 dif^3 r_2 med Phi_mu^* (bold(r)_1) Phi_nu (bold(r)_1 -bold(T)_1) times ("erfc"(omega r_12))/r_12 times Phi^*_lambda (bold(r)_2 - bold(T)_2) Phi_sigma (bold(r)_2 - bold(T)_3).
$

#figure(image("/public/images/ewald-summations/short_vs_long_range.png"))<short-vs-long-range>
