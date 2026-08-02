# Neovim Config

## How this config is managed (chezmoi) — read me first

This repo is **its own git repo**, and it is *also* pulled in by
[chezmoi](https://www.chezmoi.io/) as an **external** (see `.chezmoiexternal.toml`
in the `mickmcq/dotfiles` repo, which clones this repo into `~/.config/nvim`).
That means nvim files live in **two separate systems** — editing the wrong way
is the usual source of confusion:

| File(s) | How to edit | Where to commit |
| --- | --- | --- |
| Everything in `~/.config/nvim/` (`init.lua`, `lua/`, `colors/`, `ftplugin/`, …) | Edit the file **directly** (`nvim ~/.config/nvim/init.lua`) | **this** repo (`kickstart.nvim`) |
| `~/.config/nvim-private/personal.lua` (machine-local secrets, encrypted) | `chezmoi edit ~/.config/nvim-private/personal.lua` | the `dotfiles` repo |

Key points:

- **`chezmoi edit ~/.config/nvim/init.lua` does NOT work** — chezmoi doesn't manage
  files inside the external; it reports "not managed". Edit those directly and
  `git commit` / `git push` here.
- `personal.lua` lives **outside** `~/.config/nvim/` on purpose: chezmoi can't
  manage files *inside* a git-repo external. It is stored **age-encrypted** by
  chezmoi and loaded via a `dofile` guard at the end of `init.lua` (loads only if
  present, so machines without it still start cleanly).
- On a new machine, `chezmoi init --apply mickmcq` clones this repo into
  `~/.config/nvim` and decrypts `personal.lua` into `~/.config/nvim-private/`.

Normal workflow for editing this config:

```bash
nvim ~/.config/nvim/init.lua      # or any file under ~/.config/nvim
cd ~/.config/nvim
git add -A && git commit -m "..." && git push
```

> [!IMPORTANT]
This config is forked from the kickstart.nvim repo mentioned above. It has diverged so much that I am no longer trying pull anything in from the original repo. You should look at the original repo and other stuff from the author JMBuhr, as well as the video mentioned therein by TJ DeVries, and the related work by Folke.

