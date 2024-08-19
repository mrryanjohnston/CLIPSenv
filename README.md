# CLIPSenv

## Description

A version manager for [CLIPS](https://www.clipsrules.net/) akin to rbenv, pyenv, and nvm.
Use this to install a version of CLIPS on your computer!

## Installation

Clone [this repository](https://github.com/mrryanjohnston/CLIPSenv)
and add the `bin` dir to your `$PATH`:

```
git clone https://github.com/mrryanjohnston/clipsenv "$HOME/.clipsenv"
PATH="$HOME/.clipsenv/bin:$PATH"
clipsenv
```

The rest of the program should interactively guiding you
through installing CLIPS on your local machine.

## Requirements

- `curl` or `wget`
- `git`
