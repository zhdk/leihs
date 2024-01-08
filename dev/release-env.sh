#!/bin/sh -exu

export DEV_INITIALS=uvb
export RELEASE_MAJOR_MINOR=7.3
export RELEASE_PATCH=2
export RELEASE_PRE='-RC.1' # e.g. '-RC.1'; or '' for stable release

export RELEASE_MAIN="$RELEASE_MAJOR_MINOR.$RELEASE_PATCH"
export RELEASE="$RELEASE_MAIN$RELEASE_PRE"
export RELEASE_NAME="$RELEASE"
export LEIHS_REPO=$(pwd)

echo "RELEASE_MAIN: $RELEASE_MAIN"
echo "RELEASE: $RELEASE"
echo "RELEASE_NAME: $RELEASE_NAME"
echo "LEIHS_REPO: $LEIHS_REPO" # should be the path to your cloned leihs repository
