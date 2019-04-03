#!/bin/sh
set -e

if [ -z "$DEPLOY_VERSION_VOIKKO" ]; then
    echo "DEPLOY_VERSION_VOIKKO variable not set"
    exit 1
fi
if [ -z "$DEPLOY_VERSION_SPELLERS" ]; then
    echo "DEPLOY_VERSION_SPELLERS variable not set"
    exit 1
fi

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
    --version $DEPLOY_VERSION_VOIKKO \
    --identifier no.uit.spellers.libreoffice.voikko \
    --scripts scripts \
    build/libreoffice-installer-voikko.pkg

productbuild --distribution dist.xml \
    --version $DEPLOY_VERSION_VOIKKO \
    --package-path build/ \
    build/libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.unsigned.pkg

productsign \
    --sign "Developer ID Installer: The University of Tromso (2K5J2584NX)" \
    build/libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.unsigned.pkg \
    build/libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.pkg

rm build/libreoffice-installer-voikko.pkg
rm build/libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.unsigned.pkg    
pkgutil --check-signature build/libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.pkg

cp -a scripts build/
cd build
sh ../download_spellers.sh

for speller in se sma smj smn sms; do
    mkdir -p $speller/etc/voikko/3
    mv $speller.zhfst $speller/etc/voikko/3

    pkgbuild --root $speller \
        --ownership recommended \
        --version $DEPLOY_VERSION_SPELLERS \
        --identifier no.uit.spellers.libreoffice.$speller \
        libreoffice-speller-$speller.pkg

    productbuild --distribution ../$speller-dist.xml \
        --version $DEPLOY_VERSION_SPELLERS \
        --package-path build \
        libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.unsigned.pkg

    productsign \
        --sign "Developer ID Installer: The University of Tromso (2K5J2584NX)" \
        libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.unsigned.pkg \
        libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.pkg

    rm libreoffice-speller-$speller.pkg
    rm libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.unsigned.pkg
    pkgutil --check-signature libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.pkg
done
