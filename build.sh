#!/bin/bash

unset BUNDLE_BIN_PATH
unset MY_RUBY_HOME
unset GEM_HOME
unset BUNDLE_GEMFILE
unset GEM_PATH
unset rvm_ruby_string
unset rvm_path
unset RUBY_VERSION
unset RUBYOPT
unset IRBRC

export RAILS_ENV=production

BASE=$PWD

ARCHIVE=$BASE/../red-e-archive

DEB_BASE=$BASE/config/debian-package
OPT_BASE=$DEB_BASE/opt
SRC_BASE=$OPT_BASE/salor/hospitality

SHA_FILE=$SRC_BASE/sha1-signatures.txt

PREFIX=/opt/salor
BUNDLE=$PREFIX/ruby/bin/bundle

VERSION=`grep Version config/debian-package/DEBIAN/control | sed 's/Version: //'`
DATE="`date +%Y%m%dT%H%M%S`"

echo "Purging temp directory and logs..."
rm -rf $BASE/tmp/*
echo "" > $BASE/log/development.log
echo "" > $BASE/log/production.log
echo "" > $BASE/log/test.log

echo "Copying source tree into debian package directory..."
rm -rf $OPT_BASE
mkdir -p $SRC_BASE
cp -pr . $SRC_BASE
rm -r $SRC_BASE/.git
sed -i "s|{{VERSION}}|$VERSION-$DATE|" $SRC_BASE/config/application.rb

echo "Running bundle install..."
cd $SRC_BASE
$BUNDLE install

echo "Calculating anti-tampering SHA1 signatures..."
touch $SHA_FILE
cd $SRC_BASE
find . -type d \( -name '.git' -o -name 'debian-package' -o -name 'tmp' \) -prune -o -type f \( -name '*~' \) -prune -o -type f -exec sha1sum '{}' >> $SHA_FILE +
cp $SHA_FILE $ARCHIVE/salor-hospitality/salor-hospitality_$VERSION.sha

echo "Building Debian package..."
dpkg-deb --build $BASE/config/debian-package $ARCHIVE/salor-hospitality