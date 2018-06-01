#!/bin/sh

set -ex

### Setup latest mdbook version ################################################

mkdir -p /home/travis/.cargo/bin

INSTALLED=$(echo $(mdbook --version 2>/dev/null || echo "mdbook none") | cut -d' ' -f1)
PINNED=0.1.5

if [ "$PINNED" != "$INSTALLED" ]; then
    URL=https://github.com/rust-lang-nursery/mdBook/releases/download/v${PINNED}/mdbook-v${PINNED}-x86_64-unknown-linux-gnu.tar.gz
    curl -SsL $URL | tar xvz -C $HOME/.cargo/bin
fi

### Build the guide ################################################################
# Build and then upload the guide to a specific folder on the gh-pages branch. This way we can have multiple versions
# of the guide at the same time (See #165)

# This builds the book in target/doc/guide. See https://github.com/rust-lang-nursery/mdBook/issues/698
mdbook build -d ../target/doc/guide guide

LASTEST_TAG=$(git tag -l "v*" | tail -n1)

git clone -b gh-pages https://$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG.git gh_pages
cd gh_pages

echo "<meta http-equiv=refresh content=0;url='${LASTEST_TAG}/'>" > index.html
echo "pyo3.rs" > CNAME

# For builds triggered by a tag, $TRAVIS_BRANCH will be set to the tag
rm -rf "$TRAVIS_BRANCH"
cp -r ../target/doc/guide "$TRAVIS_BRANCH"
git add --all
git commit -m "Upload documentation for $TRAVIS_BRANCH"

git push -f
