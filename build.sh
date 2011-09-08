#!/bin/bash

JETTY_VERSION=7.4.2.v20110526
EXIST_REV=15155 #this is stable 1.4.1, following revision is version 1.5: 14611
DIGILIB_CHANGESET=cbfc94584d3b
DIGILIB_LOC=http://hg.berlios.de/repos/digilib/archive/$DIGILIB_CHANGESET.tar.bz2

SCRIPT=`readlink -f $0`
SCRIPTLOC=`dirname $SCRIPT`

BUILDLOC=$SCRIPTLOC/build
LOGDIR=$BUILDLOC/log

TEXTGRID_BUILD=false
KEEP_RUNNING=false
DO_ZIP=false

USAGE="Usage: `basename $0` [-hztr]\n -h help\n -z create sade.zip after build\n -r run SADE after build"

# Parse command line options.
while getopts hztr OPT; do
    case "$OPT" in
        h)
            echo -e $USAGE
            exit 0
            ;;
        z)
            DO_ZIP=true
            ;;
        t)
            TEXTGRID_BUILD=true
            ;;
        r)
            KEEP_RUNNING=true
            ;;
        \?)
            # getopts issues an error message
            echo -e $USAGE >&2
            exit 1
            ;;
    esac
done

# Remove the switches we parsed above.
shift `expr $OPTIND - 1`


# Create build directory
if [ ! -d $BUILDLOC ]; then
    mkdir $BUILDLOC
fi

if [ ! -d $LOGDIR ]; then
    mkdir $LOGDIR
fi

# backup old build
if [ -e $BUILDLOC/sade ]; then
    mv $BUILDLOC/sade $BUILDLOC/sade-bak-$(date +%F_%H-%M-%S)
fi

#####
#
# JETTY
# get jetty
#
# TODO:  
#
#####
echo "[SADE BUILD] get and unpack jetty"
cd $BUILDLOC

if [ ! -e $BUILDLOC/jetty-distribution-$JETTY_VERSION.tar.gz ]; then
    wget http://download.eclipse.org/jetty/$JETTY_VERSION/dist/jetty-distribution-$JETTY_VERSION.tar.gz -O $BUILDLOC/jetty-distribution-$JETTY_VERSION.tar.gz
fi

tar xfz jetty-distribution-$JETTY_VERSION.tar.gz
mv jetty-distribution-$JETTY_VERSION sade
rm sade/webapps/test.war


######
#
# EXIST
# checkout and build exist
#
# TODO: check if rev is same as checked out, if yes, no rebuild
# 
######
echo "[SADE BUILD] checkout and build eXist"
cd $BUILDLOC

BUILD_EXIST=true

if [ ! -e $BUILDLOC/exist-trunk ]; then
    svn co https://exist.svn.sourceforge.net/svnroot/exist/trunk/eXist -r $EXIST_REV exist-trunk
else 
    LOCAL_EXIST_REV=`LANG=C svn info exist-trunk/ |grep Revision | awk '{print $2}'`
    if [ $EXIST_REV != $LOCAL_EXIST_REV ]; then
        svn up -r $EXIST_REV exist-trunk
    else
        # revision did not change, and exist*.war is in place no need to rebuild
        if [ -e $BUILDLOC/exist-trunk/dist/exist*.war ];then
            echo "[SADE BUILD] found already build exist.war with correct revision"
            BUILD_EXIST=false
        fi
    fi
fi

if [ $BUILD_EXIST == true ]; then
    echo "[SADE BUILD] building eXist"
    # we want xslfo, a diff/patch may be better than sed here
    sed -i 's/include.module.xslfo = false/include.module.xslfo = true/g' exist-trunk/extensions/build.properties

    cd exist-trunk
    ./build.sh clean 
    ./build.sh 
    ./build.sh jnlp-sign-all dist-war
else
    echo "[SADE BUILD] everything in place, no need to rebuild eXist"
fi

cd $BUILDLOC/sade/webapps
mkdir exist
cd exist
unzip -q $BUILDLOC/exist-trunk/dist/exist*.war


#####
#
# DIGILIB
#
#####
echo "[SADE BUILD] get and build digilib"
cd $BUILDLOC

if [ ! -e $BUILDLOC/$DIGILIB_CHANGESET.tar.bz2 ]; then
    wget $DIGILIB_LOC -O $BUILDLOC/$DIGILIB_CHANGESET.tar.bz2
fi

tar jxf $DIGILIB_CHANGESET.tar.bz2
cd digilib-$DIGILIB_CHANGESET

#mvn package -Dmaven.compiler.source=1.6 -Dmaven.compiler.target=1.6 -Ptext -Ppdf -Pservlet2 > $LOGDIR/digilib_build.log
mvn package -Dmaven.compiler.source=1.6 -Dmaven.compiler.target=1.6 -Ptext -Ppdf -Pservlet2

cd $BUILDLOC/sade/webapps
mkdir digitallibrary
cd digitallibrary
unzip -q $BUILDLOC/digilib-$DIGILIB_CHANGESET/webapp/target/digilib*.war

mkdir $BUILDLOC/sade/images
sed -i 's/<parameter name="basedir-list" value="\/docuserver\/images:\/docuserver\/scaled\/small:\/docuserver\/scaled\/thumb" \/>/<parameter name="basedir-list" value="..\/..\/images\/" \/>/g' WEB-INF/digilib-config.xml

#####
#
# Add TextGrid stuff if requested with -t
#
#####
if [ $TEXTGRID_BUILD == true ]; then
    echo "[SADE BUILD] add textgrid specific stuff"
    cd $BUILDLOC

    if [ ! -e $BUILDLOC/tgwp ]; then
        svn co https://develop.sub.uni-goettingen.de/repos/textgrid/trunk/services/webpub/existpublish/ tgwp
    else 
        svn up tgwp
    fi

    cd tgwp

    mvn package

    cd $BUILDLOC/sade/webapps
    mkdir tgwp
    cd tgwp
    unzip -q $BUILDLOC/tgwp/target/epclient.war

fi

#####
#
# SADE Docroot
#
#####
echo "[SADE BUILD] install sade docroot"
cd $SCRIPTLOC

cp -r sade-resources/docroot $BUILDLOC/sade/docroot
mv $BUILDLOC/sade/contexts/test.xml $BUILDLOC/sade/contexts-available/
cp sade-resources/contexts/docroot.xml $BUILDLOC/sade/contexts/

mv $BUILDLOC/sade/webapps/exist/WEB-INF/conf.xml $BUILDLOC/sade/webapps/exist/WEB-INF/conf.xml.orig
cp sade-resources/exist-conf.xml $BUILDLOC/sade/webapps/exist/WEB-INF/conf.xml

####
#
# RESTORE sade xql to exist
# does not work yet, needs to fork jetty process and run restore, use restore.sh for now
##
echo "[SADE BUILD] restore sade db content to eXist"
echo "[SADE BUILD] starting sade"
cd $BUILDLOC/sade

java -jar start.jar & > $LOGDIR/sade_start.log 2>&1
SADE_PID=$!

sleep 20s
echo "[SADE BUILD] restoring backup. This may take a while, be patient"
cd $BUILDLOC/exist-trunk/
java -jar start.jar backup -r $SCRIPTLOC/sade-resources/exist-backup.zip > $LOGDIR/exist_restore.log 2>&1
#java -jar start.jar backup -r $SCRIPTLOC/sade-resources/exist-backup.zip

if [ $KEEP_RUNNING != true ];then
    kill $SADE_PID
else 
    echo "SADE running on localhost:8080, stop with 'kill $SADE_PID'"
    exit 0
fi

sleep 15s

if [ $DO_ZIP == true ]; then
    echo "[SADE BUILD] creating zipfile: $BUILDLOC/sade.zip"
    cd $BUILDLOC
    zip -rq sade.zip sade
fi

echo "[SADE BUILD] done"
echo "[SADE BUILD] you may now go to $BUILDLOC/sade and run 'java -jar start.jar'"


