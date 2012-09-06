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
PREFIX=/opt/salor
SALOR_RETAIL=$BASE/../salor_retail
SALOR_HOSPITALITY=$BASE/../salor_hospitality
SALOR_BIN=$BASE/../salor_bin
SALOR_SUPPORT=$BASE/../salor_support
SALOR_DEB=$BASE/../salor_deb
BUILD=$BASE/../build
RUBY=$PREFIX/ruby
RUBY_BIN=$RUBY/bin/salor_ruby
BUNDLE=$PREFIX/ruby/bin/bundle
RELEASE=maverick

PKG_SALOR_BIN=$BUILD/salor-bin
PKG_SALOR_RETAIL=$BUILD/salor-retail
PKG_SALOR_TRAINER=$BUILD/salor-retail-trainer
PKG_SALOR_RUBY=$BUILD/salor-ruby
PKG_SALOR_SUPPORT=$BUILD/salor-support
PKG_SALOR_HOSPITALITY=$BUILD/salor-hospitality

DEB_PUBLISH_SUBDIR=debian
LOCAL_PUBLIC_PATH=/var/www/publishr2/publishr_web/public

PUBLISHR_URL=http://publishr2.no-ip.org

VERSION="`date +%Y%m%dT%H%M%S`"

ARCHIVE_BASE=$BASE/../archive-edge
BUILD_ARCHIVE=$ARCHIVE_BASE/build/$VERSION
ANTI_TAMPERING_ARCHIVE=$ARCHIVE_BASE/anti-tampering/$VERSION

mkdir -p $BUILD_ARCHIVE
mkdir -p $ANTI_TAMPERING_ARCHIVE

SALOR_RETAIL_TAMPERING_FILE=$PKG_SALOR_RETAIL/$PREFIX/salor-retail-anti-tampering-sha1-signatures.txt
SALOR_HOSPITALITY_TAMPERING_FILE=$PKG_SALOR_HOSPITALITY/$PREFIX/salor-hospitality-anti-tampering-sha1-signatures.txt
SALOR_BIN_TAMPERING_FILE=$PKG_SALOR_BIN/$PREFIX/salor-bin-anti-tampering-sha1-signatures.txt
SALOR_RUBY_TAMPERING_FILE=$PKG_SALOR_RUBY/$PREFIX/salor-ruby-anti-tampering-sha1-signatures.txt
SALOR_SUPPORT_TAMPERING_FILE=$PKG_SALOR_SUPPORT/$PREFIX/salor-support-anti-tampering-sha1-signatures.txt


echo "*********************************************************"
echo "          Welcome to the build.sh script!"
echo "*********************************************************"
echo " "
echo "          Building Version $VERSION"

echo " "
echo "Preparation"
echo "--------------------"
echo "* Removing previous deb build directory."
rm -fr $BUILD

echo "* Creating new build directory from skeleton dir salor_deb."
cp -fr $SALOR_DEB $BUILD
rm -rf $BUILD/.git

echo " "
echo "Populating salor-retail"
echo "--------------------"
echo "* Making dir."
mkdir -p $PKG_SALOR_RETAIL/$PREFIX
echo "* Copying."
cp -fr $SALOR_RETAIL $PKG_SALOR_RETAIL/$PREFIX/retail
rm -fr $PKG_SALOR_RETAIL/$PREFIX/retail/.git
sed -i "s|{{VERSION}}|$VERSION|" $PKG_SALOR_RETAIL/$PREFIX/retail/app/models/salor_base.rb

echo " "
echo "Running bundle install for salor-retail"
echo "--------------------"
cd $PKG_SALOR_RETAIL/$PREFIX/retail
mkdir $PKG_SALOR_RETAIL/$PREFIX/retail/.bundle
cp $SALOR_DEB/bundleconfig $PKG_SALOR_RETAIL/$PREFIX/retail/.bundle/config
$BUNDLE install --deployment --without development test
rm -rf $PKG_SALOR_RETAIL/$PREFIX/retail/vendor/bundle/ruby/1.9.1/cache/*
echo "* Done."

echo " "
echo "Calculating anti-tampering SHA1 signatures for salor-retail"
echo "--------------------"
touch $SALOR_RETAIL_TAMPERING_FILE
cd $PKG_SALOR_RETAIL/$PREFIX/retail
for i in `find . -type d \( -name '.git' \) -prune -o -type f -print`
do
  sha1sum "$i" >> $SALOR_RETAIL_TAMPERING_FILE
done

echo " "
echo "Copying salor-retail to salor-retail-trainer"
echo "--------------------"
mkdir -p $PKG_SALOR_TRAINER/$PREFIX
echo "mkdir -p $PKG_SALOR_TRAINER/$PREFIX"
cp -r $PKG_SALOR_RETAIL/$PREFIX/retail $PKG_SALOR_TRAINER/$PREFIX/retail-trainer
echo "cp -r $PKG_SALOR_RETAIL/$PREFIX/retail $PKG_SALOR_TRAINER/$PREFIX/retail-trainer"
echo "* Done."


echo " "
echo "Populating salor-hospitality"
echo "--------------------"
echo "* Making dir."
mkdir -p $PKG_SALOR_HOSPITALITY/$PREFIX
echo "* Copying."
cp -fr $SALOR_HOSPITALITY $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality
rm -fr $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality/.git
sed -i "s|{{VERSION}}|$VERSION|" $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality/config/application.rb
echo "* Done."


echo " "
echo "Running bundle install for salor-hospitality"
echo "--------------------"
cd $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality
mkdir $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality/.bundle
cp $SALOR_DEB/bundleconfig $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality/.bundle/config
$BUNDLE install --deployment --without development test
rm -rf $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality/vendor/bundle/ruby/1.9.1/cache/*
echo "* Done."


echo " "
echo "Calculating anti-tampering SHA1 signatures for salor-hospitality"
echo "--------------------"
touch $SALOR_HOSPITALITY_TAMPERING_FILE
cd $PKG_SALOR_HOSPITALITY/$PREFIX/hospitality
for i in `find . -type d \( -name '.git' \) -prune -o -type f -print`
do
  sha1sum "$i" >> $SALOR_HOSPITALITY_TAMPERING_FILE
done


echo " "
echo "Populating salor-bin"
echo "--------------------"
mkdir -p $PKG_SALOR_BIN/etc/salor_pos
mkdir -p $PKG_SALOR_BIN/$PREFIX
echo "* Copying ini and binary files"
cp -f $SALOR_BIN/salor.ini $PKG_SALOR_BIN/etc/salor_pos/salor.ini
cp -f $SALOR_BIN/salor.ini $PKG_SALOR_BIN/etc/salor_pos/salor.ini
mkdir -p $PKG_SALOR_BIN/usr/bin
cp -f $SALOR_BIN/salor $PKG_SALOR_BIN/usr/bin
chmod -R a+x $PKG_SALOR_BIN/usr/bin
echo "* Done."


echo " "
echo "Calculating anti-tampering SHA1 signatures for salor-bin"
echo "--------------------"
touch $SALOR_BIN_TAMPERING_FILE
cd $PKG_SALOR_BIN
sha1sum usr/bin/salor >> $SALOR_BIN_TAMPERING_FILE




echo " "
echo "Populating salor-ruby"
echo "--------------------"
mkdir -p $PKG_SALOR_RUBY/$PREFIX
cp -fr $RUBY $PKG_SALOR_RUBY/$PREFIX
rm -rf $PKG_SALOR_RUBY/$PREFIX/ruby/share/ri/*
rm -rf $PKG_SALOR_RUBY/$PREFIX/ruby/lib/ruby/gems/1.9.1/doc/*
echo "* Done."


echo " "
echo "Calculating anti-tampering SHA1 signatures for salor-ruby"
echo "--------------------"
touch $SALOR_RUBY_TAMPERING_FILE
cd $PKG_SALOR_RUBY/$PREFIX/ruby
for i in `find . -type d \( -name '.git' \) -prune -o -type f -print`
do
  sha1sum "$i" >> $SALOR_RUBY_TAMPERING_FILE
done


echo " "
echo "Populating salor-support"
echo "--------------------"
mkdir -p $PKG_SALOR_SUPPORT/usr/bin
cp -f  $SALOR_SUPPORT/softwedge/softwedge $PKG_SALOR_SUPPORT/usr/bin
cp -f  $SALOR_SUPPORT/poledancer/poledancer $PKG_SALOR_SUPPORT/usr/bin
mkdir -p $PKG_SALOR_SUPPORT/$PREFIX
chmod -R a+x $PKG_SALOR_SUPPORT/usr/bin
echo "* Done."

echo " "
echo "Calculating anti-tampering SHA1 signatures for salor-support"
echo "--------------------"
touch $SALOR_SUPPORT_TAMPERING_FILE
cd $PKG_SALOR_SUPPORT
sha1sum usr/bin/softwedge >> $SALOR_SUPPORT_TAMPERING_FILE
sha1sum usr/bin/poledancer >> $SALOR_SUPPORT_TAMPERING_FILE


echo " "
echo "Building .deb packages"
echo "----------------------"
cd $BUILD
dpkg -b salor-bin
dpkg -b salor-retail
dpkg -b salor-retail-trainer
dpkg -b salor-hospitality
dpkg -b salor-ruby
dpkg -b salor-support
dpkg -b red-e-support
echo "* Done."


echo " "
echo "Building repositories"
echo "----------------------"
reprepro -b publish/debian includedeb $RELEASE salor-retail.deb
reprepro -b publish/debian includedeb $RELEASE salor-retail-trainer.deb
reprepro -b publish/debian includedeb $RELEASE salor-hospitality.deb
reprepro -b publish/debian includedeb $RELEASE salor-ruby.deb
reprepro -b publish/debian includedeb $RELEASE salor-bin.deb
reprepro -b publish/debian includedeb $RELEASE salor-support.deb
reprepro -b publish/debian includedeb $RELEASE red-e-support.deb
echo "* Done."

echo " "
echo "Copying repos to local download destination."
echo "--------------------------------------------"
rm -rf $LOCAL_PUBLIC_PATH/$DEB_PUBLISH_SUBDIR
cp -r $BUILD/publish/debian $LOCAL_PUBLIC_PATH/$DEB_PUBLISH_SUBDIR
echo "* Done."

echo " "
echo "Packing and archiving this build"
echo "--------------------------------"
echo "* This may take a while... "
tar cjf $BUILD_ARCHIVE/$VERSION-salor.tar.bz2 -C $BUILD/publish debian

echo "* Writing current version into CURRENT_VERSION"
echo $VERSION > $ARCHIVE_BASE/CURRENT_VERSION
echo "* Done ... "

echo "* Copying anti-tampering files"
cp $SALOR_RETAIL_TAMPERING_FILE $ANTI_TAMPERING_ARCHIVE
cp $SALOR_HOSPITALITY_TAMPERING_FILE $ANTI_TAMPERING_ARCHIVE
cp $SALOR_BIN_TAMPERING_FILE $ANTI_TAMPERING_ARCHIVE
cp $SALOR_RUBY_TAMPERING_FILE $ANTI_TAMPERING_ARCHIVE
cp $SALOR_SUPPORT_TAMPERING_FILE $ANTI_TAMPERING_ARCHIVE
echo "* Done ... "


echo " "
echo " "
echo "*********************************************************"
echo "*********************************************************"
echo "      SALOR PUBLISHING FINISHED, READY FOR DOWNLOAD"
echo "deb $PUBLISHR_URL/$PUBLISH_SUBDIR maverick main"
echo "wget $PUBLISHR_URL/$PUBLISH_SUBDIR/$VERSION-salor.tar.bz2"
echo "*********************************************************"
echo "*********************************************************"
