# blog

Source for [Niklas Paulicks'](https://blog.paulicks.com) personal blog: posts on electronic
structure theory, tensor decompositions, and programming, plus a few static pages (about,
publications, acknowledgements).

Built with [Astro](https://astro.build/), rendering articles from [Typst](https://typst.app/)
via [Tylant](https://github.com/Myriad-Dreamin/tylant). See [Acknowledgements](https://blog.paulicks.com/acknowledgements/)
for credits.

## Development

```bash
pnpm install
pnpm dev       # local dev server
pnpm build     # static build to dist/
pnpm preview   # preview the production build
```

New posts can be scaffolded with `pnpm create:post`.

## Deployment

The repo is connected to Cloudflare Pages via its GitHub integration. Pushes to
`main` build and deploy automatically; other branches/PRs get preview deployments.

## License

This repository is licensed under the [Apache License 2.0](./LICENSE).
