#!/bin/bash

SCRIPT=`readlink -f $0`
SCRIPTLOC=`dirname $SCRIPT`

BUILDLOC=$SCRIPTLOC/build
LOGDIR=$BUILDLOC/log

TEXTGRID_BUILD=false
KEEP_RUNNING=false
DO_ZIP=false
USE_TOMCAT=false
PROFILE=0

USAGE_P="-p profile:\n\t 1 -> eXist 1.4.1 (default ist 1.5 / trunk)"
USAGE="Usage: `basename $0` [-hztrp:a]\n -h help\n -z create sade.zip after build\n -r run SADE after build\n -a use apache tomcat\n $USAGE_P"


# Parse command line options.
while getopts hztrp:a OPT; do
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
            # eXist does not behave well with textgridclient on jetty -> use tomcat
            USE_TOMCAT=true
            ;;
        r)
            KEEP_RUNNING=true
            ;;
        p)
            PROFILE=$OPTARG
            ;;
        a)
            USE_TOMCAT=true
            ;;
        \?)
            # getopts issues an error message
            echo -e $USAGE >&2
            exit 1
            ;;
    esac
done

# remove the switches parsed above.
shift `expr $OPTIND - 1`

# set software locations and versions to bundle with sade

JETTY_VERSION=7.4.2.v20110526
#JETTY_VERSION=7.4.1.v20110513
#JETTY_VERSION=8.0.1.v20110908

#DIGILIB_CHANGESET=cbfc94584d3b
DIGILIB_CHANGESET=ee3383f80cb0
DIGILIB_LOC=http://hg.berlios.de/repos/digilib/archive/$DIGILIB_CHANGESET.tar.bz2

TOMCAT_VERSION=7.0.21

# choose exist version, default is 1.4.1, with -p 1 exist-trunk is chosen
case $PROFILE in
    1)
        echo "[SADE BUILD] warning: restore to 1.4.1 does not work right now"
        EXIST_BRANCH=stable/eXist-1.4.x    
        EXIST_REV=15155 #this is stable 1.4.1, following revision is version 1.5: 14611
        EXIST_SRC_LOC=exist-1.4.x
        USE_EXIST_TRUNK=false
        ;;
    *)
        EXIST_BRANCH=trunk/eXist    # exist 1.5
        EXIST_REV=15390
        EXIST_SRC_LOC=exist-trunk
        USE_EXIST_TRUNK=true
        ;;
esac

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

####
# 
#  get java application server, Jetty or Tomcat
#
###
if [ $USE_TOMCAT == true ]; then
    #####
    # get tomcat
    #####
    echo "[SADE BUILD] get and unpack tomcat $TOMCAT_VERSION"
    cd $BUILDLOC

    if [ ! -e $BUILDLOC/apache-tomcat-$TOMCAT_VERSION.tar.gz ]; then
        wget http://mirror.checkdomain.de/apache/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -O $BUILDLOC/apache-tomcat-$TOMCAT_VERSION.tar.gz
    fi

    tar xfz apache-tomcat-$TOMCAT_VERSION.tar.gz
    mv apache-tomcat-$TOMCAT_VERSION sade

    mv sade/webapps/ROOT sade/webapps/oldroot

    #####
    # SADE Docroot
    #####
    echo "[SADE BUILD] install sade docroot"
    cd $SCRIPTLOC

    cp -r sade-resources/docroot $BUILDLOC/sade/webapps/ROOT
    
else
    #####
    # get jetty
    #####
    echo "[SADE BUILD] get and unpack jetty $JETTY_VERSION"
    cd $BUILDLOC

    if [ ! -e $BUILDLOC/jetty-distribution-$JETTY_VERSION.tar.gz ]; then
        wget http://archive.eclipse.org/jetty/$JETTY_VERSION/dist/jetty-distribution-$JETTY_VERSION.tar.gz -O $BUILDLOC/jetty-distribution-$JETTY_VERSION.tar.gz
    fi

    tar xfz jetty-distribution-$JETTY_VERSION.tar.gz
    mv jetty-distribution-$JETTY_VERSION sade
    rm sade/webapps/test.war

    #####
    # SADE Docroot
    #####
    echo "[SADE BUILD] install sade docroot"
    cd $SCRIPTLOC

    cp -r sade-resources/docroot $BUILDLOC/sade/docroot
    mv $BUILDLOC/sade/contexts/test.xml $BUILDLOC/sade/contexts-available/
    cp sade-resources/contexts/docroot.xml $BUILDLOC/sade/contexts/
fi


######
#
# EXIST
# checkout and build exist
# 
######
echo "[SADE BUILD] checkout and build eXist from $EXIST_SRC_LOC"
cd $BUILDLOC

BUILD_EXIST=true

if [ ! -e $BUILDLOC/$EXIST_SRC_LOC ]; then
    svn co https://exist.svn.sourceforge.net/svnroot/exist/$EXIST_BRANCH -r $EXIST_REV $EXIST_SRC_LOC
else 
    LOCAL_EXIST_REV=`LANG=C svn info exist-trunk/ |grep Revision | awk '{print $2}'`
    if [ $EXIST_REV != $LOCAL_EXIST_REV ]; then
        svn up -r $EXIST_REV $EXIST_SRC_LOC
    else
        # revision did not change, and exist*.war is in place no need to rebuild
        if [ -e $BUILDLOC/$EXIST_SRC_LOC/dist/exist*.war ];then
            echo "[SADE BUILD] found already build exist.war with correct revision"
            BUILD_EXIST=false
        fi
    fi
fi

if [ $BUILD_EXIST == true ]; then
    echo "[SADE BUILD] building eXist"
    # we want xslfo, a diff/patch may be better than sed here
    sed -i 's/include.module.xslfo = false/include.module.xslfo = true/g' exist-trunk/extensions/build.properties

    cd $EXIST_SRC_LOC
    ./build.sh clean 
    ./build.sh 
    ./build.sh jnlp-sign-all dist-war
else
    echo "[SADE BUILD] everything in place, no need to rebuild eXist"
fi

cd $BUILDLOC/sade/webapps
mkdir exist
cd exist
unzip -q $BUILDLOC/$EXIST_SRC_LOC/dist/exist*.war


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

#mkdir $BUILDLOC/sade/images
mkdir images
sed -i 's/<parameter name="basedir-list" value="\/docuserver\/images:\/docuserver\/scaled\/small:\/docuserver\/scaled\/thumb" \/>/<parameter name="basedir-list" value="images" \/>/g' WEB-INF/digilib-config.xml

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

###
#
# exist config modification
#
###
cd $SCRIPTLOC
patch -p0 < sade-resources/existconf.xslfo.patch 

####
#
# RESTORE sade xql to exist
# TODO: backup should work for eXist 1.4.1 too
##
echo "[SADE BUILD] restore sade db content to eXist"
echo "[SADE BUILD] starting sade"
cd $BUILDLOC/sade

if [ $USE_TOMCAT = true ]; then
    bin/catalina.sh run & $LOGDIR/sade_start.log 2>&1
    SADE_PID=$!
else
    java -jar start.jar & > $LOGDIR/sade_start.log 2>&1
    SADE_PID=$!
fi

sleep 20s
echo "[SADE BUILD] restoring backup. This may take a while, be patient"
cd $BUILDLOC/$EXIST_SRC_LOC/
java -jar start.jar backup -r $SCRIPTLOC/sade-resources/exist-backup.zip > $LOGDIR/exist_restore.log 2>&1
#java -jar start.jar backup -r $SCRIPTLOC/sade-resources/exist-backup.zip
echo -e "[SADE BUILD] restore finished.\n"

####
#
#  don't kill running sade instance if requested with -r
##
if [ $KEEP_RUNNING != true ];then
    kill $SADE_PID
else 
    echo "SADE running on localhost:8080, stop with 'kill $SADE_PID'"
    exit 0
fi

sleep 15s

###
#
# create zipfile if called with -z
##
if [ $DO_ZIP == true ]; then
    echo "[SADE BUILD] creating zipfile: $BUILDLOC/sade-$EXIST_SRC_LOC.zip"
    cd $BUILDLOC
    zip -rq sade-$EXIST_SRC_LOC.zip sade
fi

echo "[SADE BUILD] done"
if [ $USE_TOMCAT = true ]; then
    echo "[SADE BUILD] you may now go to $BUILDLOC/sade and run 'bin/startup.sh'"
else
    echo "[SADE BUILD] you may now go to $BUILDLOC/sade and run 'java -jar start.jar'"
fi


