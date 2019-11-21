#!/usr/bin/env bash

cat > /home/vagrant/.vimrc <<EOD
set noeol
set nu
set et
set tabstop=4
set bg=dark
set nois
syn on

au BufRead,BufNewFile *.html set filetype=htmldjango
au BufRead,BufNewFile *.sql set filetype=mysql
EOD

cat > /home/vagrant/.bash_profile <<EOD
source /home/vagrant/.profile

set -o vi

alias ls='ls -G'

alias gl='git log --decorate --graph'
alias gb='git branch'
alias gc='git checkout'
alias gm='git merge --ff-only'
alias gs='git status'
alias gd='git diff'
alias gr='git remote -v'
alias gp='git pull --prune'

source /opt/venv/bin/activate
EOD
