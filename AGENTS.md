# Agent Instructions

## Validation commands

When running npm scripts in Gondolin, put `--prefix` after the script name:

```sh
npm run check --prefix pi/extensions/gondolin
```

Do not use `npm --prefix ... run ...`; Gondolin's allowlist rejects that form.
