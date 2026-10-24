# noisypigeon.com

**This repo is empty on purpose.** It only deploys
[noisypigeon.com](https://noisypigeon.com).

The site's source lives in
[`noisypigeon/runway`](https://github.com/noisypigeon/runway), at
[`workloads/blog/`](https://github.com/noisypigeon/runway/tree/main/workloads/blog):
its Zola site, and the DNS and redirects of the zones it owns. Write posts
there.

GitHub Pages only deploys the repository a workflow runs in, and each site has
one custom domain. So noisypigeon.com needs a repository of its own, and this is
it: one workflow, [`pages.yml`](.github/workflows/pages.yml), that builds
runway's `main` and deploys it here. runway dispatches it whenever the site
changes, by the shim its `values.yaml` names
([LIB-0031](https://github.com/noisypigeon/library/blob/main/docs/adr/LIB-0031-site-workloads-and-pages-shim-repos.md),
[LIB-0032](https://github.com/noisypigeon/library/blob/main/docs/adr/LIB-0032-move-the-blog-into-runway.md),
[LIB-0034](https://github.com/noisypigeon/library/blob/main/docs/adr/LIB-0034-site-workloads-declare-their-pages-shim.md)).
