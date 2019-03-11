#!/bin/ksh
#
# generate all packages, in both datastream and zap formats, from
# an installed system
#
# these ought to be args
#
PKG_VERSION="0.9o"
THOME=${THOME:-/packages/localsrc/Tribblix}
DSTDIR=/var/tmp/created-pkgs

CMD=${THOME}/tribblix-build/ips2svr4.sh
PNAME=${THOME}/tribblix-build/pkg_name.sh
PKG2ZAP=${THOME}/tribblix-build/pkg2zap

cd /var/pkg/publisher/openindiana.org/pkg

for file in *
do
    echo Packaging $file as `$PNAME $file`
    $CMD -T $THOME -V $PKG_VERSION -D $DSTDIR $file `$PNAME $file`
done

#
# convert the SVR4 pkg to zap format
# create an md5 checksum for the catalog
# optionally sign if we have a signing passphrase
#
for file in ${DSTDIR}/pkgs/*.pkg
do
    $PKG2ZAP $file ${DSTDIR}/pkgs
    openssl md5 ${file%.pkg}.zap | /usr/bin/awk '{print $NF}' > ${file%.pkg}.zap.md5
    if [ -f ${HOME}/Tribblix/Sign.phrase ]; then
	echo ""
	echo "Signing package."
	echo ""
	gpg --detach-sign --no-secmem-warning --passphrase-file ${HOME}/Tribblix/Sign.phrase ${file%.pkg}.zap
	if [ -f ${file%.pkg}.zap.sig ]; then
	    echo "Package signed successfully."
	    echo ""
	fi
    fi
done
