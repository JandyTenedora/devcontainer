#!/bin/sh
case "$1" in
  Username*) echo "git" ;;
  *) echo "$GIT_TOKEN" ;;
esac
