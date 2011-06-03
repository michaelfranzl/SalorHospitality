#!/bin/sh

cd config/packages

echo "Removing old build products"
rm -f *.deb
rm -rf publish/debian/db
rm -rf publish/debian/dists
rm -rf publish/debian/pool

echo "Copy compiled Ruby and essential Gems"
cp -r ~/Public/opt billgastro-bin

echo "Copy BillGastro Source from git repository"
rm -rf billgastro-src/opt
mkdir -p billgastro-src/opt/billgastro
git clone ../.. billgastro-src/opt/billgastro/billgastro
rm -rf billgastro-src/opt/billgastro/billgastro/.git

dpkg -b billgastro
dpkg -b billgastro-src
dpkg -b billgastro-bin

reprepro -b publish/debian includedeb maverick billgastro.deb
reprepro -b publish/debian includedeb maverick billgastro-src.deb
reprepro -b publish/debian includedeb maverick billgastro-bin.deb

# local hosting for quick virtualbox testing
rm -rf /var/www/80/debian
cp -r publish/debian /var/www/80
