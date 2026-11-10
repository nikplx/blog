#import "/typ/templates/blog.typ": *
#import "../../templates/env.typ": url-base
#show: main.with(
  title: "K-Point ISDF (Version 1)",
  desc: [],
  date: "2026-11-09",
  tags: (
    blog-tags.electronic-structure,
    blog-tags.tensor-decomposition,
  ),
)

= Using precalculated grid decompositions for K-Point ISDF

This is an idea from the 2026 paper *Ab Initio Many Body Quantum Embedding and Local Correlation in Crystalline Materials using Interpolative Separable Density Fitting* (https://arxiv.org/abs/2601.16379) by Yang and colleagues. I want to provide some more details that are left out of the paper for brevity but that are important when implementing this factorization. I will change some of the nomenclature of the paper and reuse some other. I want to achieve an intuitive understand of the topic myself, so I will trade some mathematical rigor for more analogy driven explanations at some points. 

I already wrote a #link(url-base + "article/supercell-isdf")[Post] where I detail the application of the method proposed by Yang et. al. for Gamma-Cell (only one k-point) calculations. This post details, how to adapt it for multi-point meshes.

== What is a k-point?
 
 When treating periodic quantum systems certain modeling choices made in molecular systems do not transfer and have to be amended. A nicely written review article *Wavefunction-based periodic quantum chemistry* (#link("http://arxiv.org/abs/2607.28554")) was recently published by Ye and Berkelbach. 

 Most importantly, treating periodic systems implies the use of Periodic Boundary Conditions in which we define replicate our system infinitely often towards the boundaries. So for a given system an electron in our system will not only interact with all other electrons in the system but also with all periodic images of itself as well as the other electrons in the crystal. This leads to a periodic formulation of the potential which can be written as
 $

 $
