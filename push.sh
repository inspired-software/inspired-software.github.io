#!/bin/zsh
git push origin $(git subtree split --prefix Output master):gh-pages --force
