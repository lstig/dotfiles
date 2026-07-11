# yt-dlp package

Stow package for [yt-dlp](https://github.com/yt-dlp/yt-dlp) configuration.
Installs `~/.config/yt-dlp/`.

## Structure

```
.config/yt-dlp/
├── config                  # default CLI options (retries, retry backoff)
└── plugins/                # yt-dlp plugin tree
```

`config` holds default command-line options applied to every invocation.
`plugins/` follows yt-dlp's plugin layout (e.g. `<pkg>/yt_dlp_plugins/extractor/`).

`plugins/` is git-ignored: it stays in the working tree so stow's directory
symlink still exposes it under `~/.config/yt-dlp/plugins/`, but it is not
tracked in this repo. Python bytecode caches (`__pycache__/`) are likewise
excluded via `.gitignore`.
