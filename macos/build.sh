#!/bin/sh
set -e

. version.sh

rm -rf build || true
mkdir build
cd build
mkdir -p pkg-root/etc/voikko
git clone https://github.com/divvun/divvun-ci-config.git
cd divvun-ci-config
sh ./install-macos.sh

cd ..
mkdir voikko
cd voikko
svn checkout https://gtsvn.uit.no/langtech/trunk/giella-libs/LibreOffice-voikko/5.0
cd 5.0
zip -r ../../pkg-root/etc/voikko/voikko-5.0.oxt *
cd ../../..

pkgbuild --root build/pkg-root \
    --ownership recommended \
    --version $DEPLOY_VERSION \
    --identifier no.uit.spellers.libreoffice.voikko \
    --scripts scripts \
    build/libreoffice-voikko.pkg

productbuild --distribution dist.xml \
    --version $DEPLOY_VERSION \
    --package-path build/ \
    build/libreoffice-voikko-$DEPLOY_VERSION.unsigned.pkg

productsign \
    --sign "Developer ID Installer: The University of Tromso (2K5J2584NX)" \
    build/libreoffice-voikko-$DEPLOY_VERSION.unsigned.pkg \
    build/libreoffice-voikko-$DEPLOY_VERSION.pkg

rm build/libreoffice-voikko.pkg
rm build/libreoffice-voikko-$DEPLOY_VERSION.unsigned.pkg    
pkgutil --check-signature build/libreoffice-voikko-$DEPLOY_VERSION.pkg

mv build/libreoffice-voikko-$DEPLOY_VERSION.pkg build/libreoffice-voikko.pkg
