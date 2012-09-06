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

DEB_BASE=config/debian-package
OPT_BASE=$DEB_BASE/opt
SRC_BASE=$OPT_BASE/salor/hospitality

PREFIX=/opt/salor
BUNDLE=$PREFIX/ruby/bin/bundle



VERSION=`grep Version config/debian-package/DEBIAN/control | sed 's/Version: //'`

echo "Copying source tree into debian package directory..."
rm -r $OPT_BASE
mkdir -p $SRC_BASE
cp -pr . $SRC_BASE
rm -r $SRC_BASE/.git
sed -i "s|{{VERSION}}|$VERSION|" $SRC_BASE/config/application.rb

echo "Running bundle install..."
cd $SRC_BASE
$BUNDLE install

echo "Purging temp directory..."
rm -rf $SRC_BASE/tmp/*



SALOR_HOSPITALITY_TAMPERING_FILE=$PKG_SALOR_HOSPITALITY/$PREFIX/salor-hospitality-anti-tampering-sha1-signatures.txt

echo " "
echo "Calculating anti-tampering SHA1 signatures..."
echo "--------------------"
#touch $SRC_BASE/sha1-signatures.txt
cd $SRC_BASE
for i in `find . -type d \( -name '.git' -o -name 'debian-package' -o -name 'tmp' \) -prune -o -type f \( -name '*~' \) -prune -o -type f -print`
do
  sha1sum "$i" >> $SRC_BASE/sha1-signatures.txt
done


echo "Building Debian package..."
dpkg-deb --build . .


