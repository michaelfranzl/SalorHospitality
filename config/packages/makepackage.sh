#!/bin/sh

cd config/packages

# remove old build products
rm -f *.deb
rm -rf publish/debian/db
rm -rf publish/debian/dists
rm -rf publish/debian/pool

echo "Copy compiled Ruby, Gems and configuration files"
cp -r ~/Public/pack/usr billgastro-bin
cp -r ~/Public/pack/etc billgastro-src

echo "Copy BillGastro Source from git repository"
rm -rf billgastro-src/var
mkdir -p billgastro-src/var/www
git clone ../.. billgastro-src/var/www/billgastro
rm -rf billgastro-src/var/www/billgastro/.git

dpkg -b billgastro
dpkg -b billgastro-src
dpkg -b billgastro-bin

reprepro -b publish/debian includedeb maverick billgastro.deb
reprepro -b publish/debian includedeb maverick billgastro-src.deb
reprepro -b publish/debian includedeb maverick billgastro-bin.deb

# local hosting for quick virtualbox testing
rm -rf /var/www/80/debian
cp -r publish/debian /var/www/80

ncftpput -R -u billgastroweb-www -p QXP3mSUq -m billgastro.com public publish/debian
