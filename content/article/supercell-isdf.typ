#import "/typ/templates/blog.typ": *
#show: main.with(
  title: "Supercell ISDF",
  desc: [],
  date: "2026-08-29",
  tags: (
    blog-tags.electronic-structure,
    blog-tags.tensor-decomposition,
  ),
)

#import "@preview/drawmatrix:0.1.0": drawmatrix
#let dm = drawmatrix.with(stroke: black.lighten(50%))
#let dmbig = dm.with(scale: 2, upper: true)
#let dmtall = dm.with(height: 2)

#let dm3x1 = dm.with(height: 3, width: 1)
#let dm1x3 = dm.with(height: 1, width: 3)

#let dm2x1 = dm.with(height: 2, width: 1)
#let dm1x2 = dm.with(height: 1, width: 2)

#let dm2x3 = dm.with(height: 2, width: 3)
#let dm3x2 = dm.with(height: 3, width: 2)

#let nxg = dm3x2
#let nxp = dm3x1
#let pxg = dm1x2
#let gxp = dm2x1
#let pxp = dm.with(width: 1, height: 1)

#let dmwide = dm.with(width: 2)
#let dmbigsquare = dm.with(height: 3, width: 2)
#let dmsmall = dm.with(upper: true)


= THC/ISDF in Supercell / Gamma Point calculations

  This is an idea from the 2026 paper *Ab Initio Many Body Quantum Embedding and Local Correlation in Crystalline Materials using Interpolative Separable Density Fitting* (https://arxiv.org/abs/2601.16379) by Yang and colleagues. I want to provide some more details that are left out of the paper for brevity but that are important when implementing this factorization. I will change some of the nomenclature of the paper and reuse some other.

We want to factorize 
$
(mu nu|lambda sigma) approx X^P_mu X^P_nu Z^(P Q) X^Q_lambda X^Q_sigma.
$

For this, we introduce an evenly spaced grid $G$, which we index with $g, h$ and calculate

$
X_mu^h = chi_mu (bold(r)_g) space forall  bold(r)_g in G
$

by using the ISDF style expression for the center Coulomb matrix $bold(Z)$:
$
bold(Z) = integral dif r_1 dif r_2 (xi_P (r_1) xi_Q (r_2))/norm(r_1-r_2) 
$

which we found from the Interpolative Decomposition of the Co-density $bold(C)$
$
X_mu^g ⊙ X_nu^g = C_(mu nu)^g approx sum_P K_(mu nu)^P xi_P^g.
$

The ID interpolation points (indexed by $P$) can be computed using a pivoted Cholesky Decomposition of the grid metric matrix
$
S_(g h) = sum_(mu nu) X_mu^g X_nu^g X_mu^h X_nu^h \

bold(S) approx sum_P L_g^P L_h^P.
$

The ID gives us matrices of the form
$
nxp(K) dot pxg(xi) approx nxg(C)  \
$

which represent an overtedermined system of equations, since we generally have $N^2$ equations for $N_"THC"$  many equations with  $N_"ISDF" << N^2$, which we need to solve $N_"grid"$ times.

For overdetermined systems, we can run into problems as there might be *no solution* that satisfies all of our equations. But we can find a linear least squares solution by using
$
min norm(bold(A) bold(x) - bold(b))^2_2
$

which gives us the normal equation 
$
A^T A x = A^T b.
$
This we derive by means of calculating the gradient of $(A x - b)^T (A x - b)$ with respect to $x$ and setting it to zero, which in our case gives us
$
(bold(K)^T bold(K)) &&bold(xi) &= bold(K) bold(C) \
sum_Q underbrace((sum_(mu nu) X_mu^P X_nu^P X_mu^Q X_nu^Q), Pi_(P Q)) &&xi^Q_g &= underbrace(sum_(mu nu) X_mu^P X_nu^P X_mu^g X_nu^g, S_(P g))
$

which in matrix representation is
$
pxp(Pi) dot pxg(xi) = pxg(S)
$

This boils down to just an $A x = b$ expression for each column of the $N_"grid"$ columns in $xi$. The pruned grid metric $S_(P Q)$ is sometimes also denoted as $bold(Pi)$ and the grid vs. pruned grid metric (sometimes called Right Hand Side - RHS vector)  is sometimes denoted as $bold(eta)$. I find it clearer to use the index labels, as it shows the underlying math expression for both metrics are identical.


In theory we could just compute $xi$ using standard solving procedures and then use FFT to calculate $bold(Z)$, but we also avoid this by realizing that both $xi$ and $S$ project into the $N_"grid"$ column space, which means we can reformulate the equation

$
pxg(xi) = pxp(Pi)^(space -1) dot space pxg(S) \
$
and plugging this into our integral expression for $bold(Z)$
$
pxp(Z) &= integral pxg(xi) 1/norm(r_12) gxp(xi) dif r_12  \
       &= pxp(Pi)^(space -1) dot (integral  pxg(S)  1/norm(r_12) gxp(S) dif r_12) space dot pxp(Pi)^(space -1)
$


where we can pull out $bold(Pi)$ as it has no dependence on the full real space grid indexed by $r_1$ and $r_2$. We now need to evaluate 
$
V_(P Q) = integral S_(P g) S_(Q h) 1/norm(r_g - r_h) dif r_g dif r_h.
$

which we can do by using the convolution theorem that states that 

$
integral u(tau) v(x - tau) dif tau = cal(F)^(-1) { U dot V} 
$

i.e. a convolution the real-domain becomes a multiplication in the Fourier transformed version of the space. Here 
$
U = cal(F){u} "and" V = cal(F){v}
$
We can use this be realizing that if we write our ISDF integral representation in a separated form, such that one variable is integrated out
$
V_(P g) = integral S_(P g) 1/norm(r_g - r_h) dif r_h
$

and transform it to one "function-like" equation per $P$ point
$
(V(g))_P = (integral S(r_g) 1/norm(r_g - r_h) dif r_h)_P = (integral S(r_g) v(r_g-r_h) dif r_h)_P
$
it is just a convolution and can therefore be solved by 
$
(V(g))_P = (cal(F)^(-1) { cal(F){S} compose cal(F){v} })_P
$

where $compose$ denotes a hadamard product between the matrices. 
*This only works as long as our grid we apply the transformation along (i.e. $g,h$) is evenly spaced!*
Since this is the case, we can find the Fourier transformed Coulomb function as by expanding the standard Coulomb function as a Fourier series over the reciprocal lattice vectors $G$
$
v(bold(r)) = 1/abs(bold(r)) = sum_G v_G e^(i G dot r)
$

which we can plug into Poissons equation

$
nabla^2 v(bold(r)) &= -4 pi delta (r) \
nabla^2 sum_G v_G e^(i G dot r) &= -4 pi  sum_G e ^(i G dot r).
$

Here we also expanded the Dirac delta. Now we can let the Laplace operator act on the expanded version and it pulls down two times $i G$, so we get 
$
sum_G (i G) (i G) v_G space cancel(e^(i G dot r)) &= -4 pi cancel(sum_G e^(i G dot r)) \
sum_G -abs(G)^2 v_G space &= -4 pi \
v_G &= (4 pi) / (abs(G)^2) 
$
where $bold(G_g)$ is the reciprocal space lattice vectors at grid point $g$. 

Now we want to directly evaluate the double sided equation

$
V_(P Q) = integral S_(P g)  1/norm(r_g - r_h) S_(Q h) dif r_g dif r_h.
$

by using the convolution theorem on the function

$
Phi_Q (r_g) = integral v(r_g - r_h) S_Q (r_h) dif r_h = (v * S_Q) (r_g).
$

We solve it algorithmically by calculating
$
cal(F){Phi_Q} = [cal(F){ v * S_Q }] = cal(F){v} compose cal(F){S_Q} = (4 pi)/abs(G_g)^2  cal(F){S}_(Q g)
$

Now we can apply Perseval's theorem about the integral of Fourier transformed functions $f$ and $g$, which states that 
$
integral f^*(r) g(r) dif r = 1/Omega sum_G cal(F){f}^* (G) cal(F){g}(G)
$

where an upper $*$ marks complex conjugation and $Omega$ denotes the volume of our unit cell.
Applied to our functions this yields our final expression for $bold(V)$
$
V_(P Q) = 1/Omega sum_G cal(F){S_P}^* (G)  cal(F){Phi_Q} (G)
$

and we do so algorithmically by evaluating the inner product

$
bold(V) = Re[1/Omega space (cal(F){bold(S)})^dagger (4 pi)/abs(bold(G))^2 cal(F){bold(S)}].
$

Note that we can just take the real part here as there is only one Gamma point and our orbitals are real-valued.

With $bold(V)$ available, we can exploit our Cholesky vectors $bold(L)$ from the start to calculate $bold(Z)$ by using intermediates and triangular solves

$
bold(Z) &= bold(Pi)^(-1) bold(V) bold(Pi)^(-1) \
        &= [bold(L) bold(L)^T]^(-1) bold(V) [bold(L) bold(L)^T]^(-1) \
        &= [bold(L)^T]^(-1) bold(L)^(-1) bold(V) [bold(L)^T]^(-1) bold(L)^(-1) \

$
$
bold(A) &= bold(L)^(-1) bold(V) -> bold(L) bold(A) = bold(V) -> "solve for" bold(A) \
bold(B) &= [bold(L)^T]^(-1) bold(A) -> bold(L)^T bold(B) = bold(A) -> "solve for" bold(B)\
bold(C) &= bold(B) [bold(L)^T]^(-1) -> bold(L) bold(C)^T = bold(B)^T -> "solve for" bold(C)\
bold(Z) &= bold(C) bold(L)^(-1) -> bold(L) bold(Z)^T = bold(C)^T -> "solve for" bold(Z)\
$



