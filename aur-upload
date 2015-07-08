#!/bin/bash

set -e

test -f PKGBUILD

newpkg=0
pkgname="$(. PKGBUILD && echo "${pkgname}")"
pkgver="$(. PKGBUILD && echo "${pkgver}")"
pkgrel="$(pkgrel=1 && . PKGBUILD && echo "${pkgrel}")"
epoch="$(epoch=0 && . PKGBUILD && echo "${epoch}")"
install="$(install="" && . PKGBUILD && echo "${install}")"

if [ ! -d .aur ]; then
    newpkg=1
    git clone "ssh://aur@aur4.archlinux.org/${pkgname}.git" .aur
fi

version="${pkgver}"
if [ ! "${epoch}" = 0 ]; then
    version="${epoch}:${version}"
fi
if [ ! "${pkgrel}" = 1 ]; then
    version="${version}-${pkgrel}"
fi

cp PKGBUILD .aur
if [ ! "${install}" = "" ]; then
    cp "${install}" .aur
    cd .aur
    git add "${install}"
    cd ..
fi

(
    . PKGBUILD
    cd .aur
    for file in "${source[@]}"; do
	if [ -f ../"${file}" ]; then
	    cp ../"${file}" .
	    git add "${file}"
	fi
    done
    cd ..
)

cd .aur

mksrcinfo
git add PKGBUILD .SRCINFO

if [ ${newpkg} = 1 ]; then
    git commit -m "Initial import, version ${version}"
    git push origin master
elif [ ! "${pkgrel}" = 1 ]; then
    git commit -m "Update package release to ${version}"
    git push
else
    git commit -m "Update to ${version}"
    git push
fi

