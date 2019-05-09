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
if [ -z "$PAHKAT_REPO_NAME" ]; then
    echo "PAHKAT_REPO_NAME variable not set"
    exit 1
fi
if [ -z "$BRANCH" ]; then
    echo "BRANCH variable not set"
    exit 1
fi
if [ -z "$DEPLOY_SVN_URL" ]; then
    echo "DEPLOY_SVN_URL variable not set"
    exit 1
fi
if [ -z "$DEPLOY_SVN_USER" ]; then
    echo "DEPLOY_SVN_USER variable not set"
    exit 1
fi
if [ -z "$DEPLOY_SVN_PASSWORD" ]; then
    echo "DEPLOY_SVN_PASSWORD variable not set"
    exit 1
fi

PAHKAT_PACKAGE_NAME="libreoffice-voikko"
DEPLOY_AS="$PAHKAT_PACKAGE_NAME-$(date -u +%Y%m%dT%H%M%SZ).pkg"
DEPLOY_ARTIFACT_PATH=../libreoffice-installer-voikko-$DEPLOY_VERSION_VOIKKO.pkg
INTERMEDIATE_REPO=./build/deploy-repo

rm -rf INTERMEDIATE_REPO || true

# checkout the svn repo to use for deployment
# into the build folder
svn checkout --depth immediates $DEPLOY_SVN_URL $INTERMEDIATE_REPO
cd $INTERMEDIATE_REPO
svn up packages --set-depth=infinity
svn up virtuals --set-depth=infinity
svn up index.json

if [ ! -f $DEPLOY_ARTIFACT_PATH ]; then
    echo "Deploy artifact not found at: $DEPLOY_ARTIFACT_PATH"
    exit 1
fi

# determine if the application binary has already 
# been added to version control, then do add or up
set +e
svn info ./artifacts/$DEPLOY_AS

if [[ $? != 0 ]]; then
    set -e
    cp $DEPLOY_ARTIFACT_PATH ./artifacts/$DEPLOY_AS
    svn add ./artifacts/$DEPLOY_AS
else
    set -e
    svn up ./artifacts/$DEPLOY_AS
    cp $DEPLOY_ARTIFACT_PATH ./artifacts/$DEPLOY_AS
fi

# update the pahkat package description
DEPLOY_FILE_SIZE=$(stat -f %z -- "$DEPLOY_ARTIFACT_PATH")
cat ../../pahkat-template.json | sed "s|DEPLOY_VERSION|$DEPLOY_VERSION_VOIKKO|g" | sed "s|DEPLOY_FILE_NAME|$DEPLOY_AS|g" | sed "s|DEPLOY_FILE_SIZE|$DEPLOY_FILE_SIZE|g" | sed "s|DEPLOY_SVN_URL|$DEPLOY_SVN_URL|g" > packages/$PAHKAT_PACKAGE_NAME/index.json

for speller in se sma smj smn sms; do
    PAHKAT_PACKAGE_NAME=libreoffice-speller-$speller
    DEPLOY_AS="$PAHKAT_PACKAGE_NAME-$(date -u +%Y%m%dT%H%M%SZ).pkg"
    DEPLOY_ARTIFACT_PATH=../libreoffice-speller-$speller-$DEPLOY_VERSION_SPELLERS.pkg

    if [ ! -f $DEPLOY_ARTIFACT_PATH ]; then
        echo "Deploy artifact not found at: $DEPLOY_ARTIFACT_PATH"
        exit 1
    fi

    # determine if the application binary has already 
    # been added to version control, then do add or up
    set +e
    svn info ./artifacts/$DEPLOY_AS

    if [[ $? != 0 ]]; then
        set -e
        cp $DEPLOY_ARTIFACT_PATH ./artifacts/$DEPLOY_AS
        svn add ./artifacts/$DEPLOY_AS
    else
        set -e
        svn up ./artifacts/$DEPLOY_AS
        cp $DEPLOY_ARTIFACT_PATH ./artifacts/$DEPLOY_AS
    fi

    # update the pahkat package description
    DEPLOY_FILE_SIZE=$(stat -f %z -- "$DEPLOY_ARTIFACT_PATH")
    cat ../../pahkat-template-$speller.json | sed "s|DEPLOY_VERSION|$DEPLOY_VERSION_SPELLERS|g" | sed "s|DEPLOY_FILE_NAME|$DEPLOY_AS|g" | sed "s|DEPLOY_FILE_SIZE|$DEPLOY_FILE_SIZE|g" | sed "s|DEPLOY_SVN_URL|$DEPLOY_SVN_URL|g" > packages/$PAHKAT_PACKAGE_NAME/index.json
done

# re-index using pahkat
pahkat repo index

# run svn status to get the changes logged
# then optionally commit changes
svn status
if [ -n "$DEPLOY_SVN_COMMIT" ]; then
    svn commit -m "Automated Deploy to $PAHKAT_REPO_NAME: libreoffice spellers" --username=$DEPLOY_SVN_USER --password=$DEPLOY_SVN_PASSWORD
else
    echo "Warning: DEPLOY_SVN_COMMIT not set, ie. changes to repo will not be commited"
fi

cd ..
