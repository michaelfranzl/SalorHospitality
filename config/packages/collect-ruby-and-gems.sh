#!/bin/sh

rm -rf /media/sf_Public/opt
mkdir -p /media/sf_Public/opt/billgastro

cd /media/sf_Public/opt/billgastro

cp -r /opt/billgastro/bin .
cp -r /opt/billgastro/include .
cp -r /opt/billgastro/lib .

# delete not needed files to reduce download size
rm -rf lib/ruby/gems/1.9.1/cache
rm -rf lib/ruby/gems/1.9.1/doc
rm -rf lib/ruby/gems/1.9.1/gems/passenger-3.0.7/doc
