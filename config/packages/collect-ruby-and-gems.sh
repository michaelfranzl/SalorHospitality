#!/bin/sh

rm -rf /media/sf_Public/pack
mkdir -p /media/sf_Public/pack/usr/local/lib/ruby/gems/1.9.1

cp -vpr /usr/local/bin /media/sf_Public/pack/usr/local
cp -vpr /usr/local/include /media/sf_Public/pack/usr/local

cp -vpr /usr/local/lib/ruby/1.9.1 /media/sf_Public/pack/usr/local/lib/ruby
cp -vpr /usr/local/lib/ruby/gems/1.9.1/cache /media/sf_Public/pack/usr/local/lib/ruby/gems/1.9.1
cp -vpr /usr/local/lib/ruby/gems/1.9.1/gems /media/sf_Public/pack/usr/local/lib/ruby/gems/1.9.1
cp -vpr /usr/local/lib/ruby/gems/1.9.1/specifications /media/sf_Public/pack/usr/local/lib/ruby/gems/1.9.1

cp -vpr /usr/local/lib/libruby-static.a /media/sf_Public/pack/usr/local/lib

mkdir -p /media/sf_Public/pack/etc/apache2/mods-enabled
mkdir -p /media/sf_Public/pack/etc/apache2/sites-enabled
mkdir -p /media/sf_Public/pack/etc/profile.d

cp -vpr /etc/apache2/mods-enabled/rails* /media/sf_Public/pack/etc/apache2/mods-enabled
cp -vpr /etc/apache2/sites-enabled/billgastro /media/sf_Public/pack/etc/apache2/sites-enabled
cp -vpr /etc/profile.d/billgastro.sh /media/sf_Public/pack/etc/profile.d
