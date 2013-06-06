#!/bin/sh

VERSION="$1"

if [ "x$VERSION" == "x" ]; then
  echo "Usage: $0 VERSION" >&2
  exit 1
fi

sed -i '' -E 's/"version": "[^"]+"/"version": "'"$VERSION"'"/' package.json
git add package.json
git commit -m "Bumped $VERSION"
git tag "$VERSION" HEAD
git push origin
git push origin --tags
npm publish
