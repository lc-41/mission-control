## uploading new tapes

First time setup: Get a personal access token via https://github.com/settings/tokens/new?scopes=write:packages, then use `skopeo login` with your GitHub username and **your personal access token as your password**.

```
skopeo copy --digestfile /dev/stdout tarball:tapes.tar.gz docker://ghcr.io/lc-41/tapes
```

`tapes.tar.gz` should have `tapes` and `zstd-directories` at the top level; the contents of the container image are copied directly into the `data` directory of the disc.
