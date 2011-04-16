#!/bin/sh

rm -rf $1/var/www/billgastro
rm -f $1.deb
rm -rf $1/../publish/debian/db
rm -rf $1/../publish/debian/dists
rm -rf $1/../publish/debian/pool

echo "Copy compiled Ruby, Gems and configuration files"
cp -rf ~/Public/pack/* $1

echo "Copy BillGastro Source from git repository"
mkdir -p $1/var/www
cd $1/var/www
git clone -b billgastro3 ../..
rm -rf billgastro/.git
cd -

dpkg -b $1
reprepro -b $1/../publish/debian includedeb maverick $1.deb

rm -rf /var/www/80/debian
cp -r publish/debian /var/www/80

ncftpput -R -u billgastroweb-www -p QXP3mSUq -m billgastro.com public $1/../publish/debian

rm -f $1.deb
