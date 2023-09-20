#!/bin/sh

bat --paging=never --style=numbers --terminal-width $(($2-5)) -f "$1"
