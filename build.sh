#!/bin/bash

SCRIPT=`readlink -f $0`
SCRIPTLOC=`dirname $SCRIPT`

BUILDLOC=$SCRIPTLOC/build
LOGDIR=$BUILDLOC/log

TEXTGRID_BUILD=false
KEEP_RUNNING=false
DO_ZIP=false
USE_TOMCAT=false

USAGE="Usage: `basename $0` [-hztra]\n -h help\n -z create sade.zip after build\n -r run SADE after build\n -a use apache tomcat\n"

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

#Jetty
JETTY_VERSION=8.0.3.v20111011

# digilib (setting "tip" as changeset gets head revision)
#DIGILIB_CHANGESET=a1bb909dfd38
DIGILIB_CHANGESET=36102de2301e
#DIGILIB_CHANGESET=tip
DIGILIB_LOC=http://hg.berlios.de/repos/digilib/archive/$DIGILIB_CHANGESET.tar.bz2

# tomcat
TOMCAT_VERSION=7.0.23

# exist
#EXIST_BRANCH=trunk/eXist    # exist 1.5
#EXIST_REV=15655
#EXIST_SRC_LOC=exist-trunk
EXIST_BRANCH=stable/eXist-2.0.x    # exist 1.5
#EXIST_REV=-1					   # revision to check out -1 means head
EXIST_REV=16134
EXIST_SRC_LOC=exist-2.0

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
        wget http://archive.apache.org/dist/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -O $BUILDLOC/apache-tomcat-$TOMCAT_VERSION.tar.gz
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
	cp $BUILDLOC/sade/bin/catalina.sh $BUILDLOC/sade/bin/sade.sh
	cp $BUILDLOC/sade/bin/catalina.bat $BUILDLOC/sade/bin/sade.bat
    
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

	#####
    # SADE startup
    #####
	echo "[SADE BUILD] patch jetty.sh to make sure tmpdir is set to JETTY_HOME/tmp"
	mkdir $BUILDLOC/sade/tmp
	cd $BUILDLOC/sade/bin
	patch -p0 < ../../../sade-resources/jetty.sh.patch
	cp jetty.sh sade.sh
    cp jetty-cygwin.sh sade-cygwin.sh
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
	# exist rev < 0 means head
	if [ $EXIST_REV -lt 0 ]; then
		svn co https://exist.svn.sourceforge.net/svnroot/exist/$EXIST_BRANCH $EXIST_SRC_LOC
	else
    	svn co https://exist.svn.sourceforge.net/svnroot/exist/$EXIST_BRANCH -r $EXIST_REV $EXIST_SRC_LOC
	fi
else 
    LOCAL_EXIST_REV=`LANG=C svn info $EXIST_SRC_LOC |grep Revision | awk '{print $2}'`
	# exist rev < 0 means head
	if [ $EXIST_REV -lt 0 ]; then
		svn up $EXIST_SRC_LOC
	else
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
fi

if [ $BUILD_EXIST == true ]; then
    echo "[SADE BUILD] building eXist"
    # we want xslfo, a diff/patch may be better than sed here
    sed -i 's/include.module.xslfo = false/include.module.xslfo = true/g' $EXIST_SRC_LOC/extensions/build.properties

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
# SADE Packages
# build xar packages
#
#####

echo "[SADE BUILD] building xar packages for SADE"
cd $SCRIPTLOC/packages
ant

# TODO: put into local public repo? / set EXIST_HOME for  
# repo location EXIST_HOME/webapp/WEB-INF/expathrepo instead of /tmp/expathrepo
echo "[SADE BUILD] put xar packages into eXist local repository"
cp build/*.xar $BUILDLOC/sade/webapps/exist/repo/packages

#####
#
# DIGILIB
#
# TODO: use mercurial instead of the bzip download
#####
echo "[SADE BUILD] get and build digilib"
cd $BUILDLOC

if [ $DIGILIB_CHANGESET == 'tip' ]; then
	mkdir digilib-$DIGILIB_CHANGESET
	cd digilib-$DIGILIB_CHANGESET
	tar --strip-components=1 --overwrite -jxf ../$DIGILIB_CHANGESET.tar.bz2
else 
	if [ ! -e $BUILDLOC/$DIGILIB_CHANGESET.tar.bz2 ]; then
		wget $DIGILIB_LOC -O $BUILDLOC/$DIGILIB_CHANGESET.tar.bz2
	fi
	tar -jxf $DIGILIB_CHANGESET.tar.bz2
	cd digilib-$DIGILIB_CHANGESET
fi

mvn clean

echo "[SADE BUILD] building async version (servlet api3)"
#mvn package -Dmaven.compiler.source=1.6 -Dmaven.compiler.target=1.6 -Ptext -Ppdf -Pservlet3 -Pcodec-bioformats -Pcodec-imagej -Pcodec-jai
mvn package -Dmaven.compiler.source=1.6 -Dmaven.compiler.target=1.6 -Ptext -Ppdf -Pservlet3

cd $BUILDLOC/sade/webapps
mkdir digitallibrary
cd digitallibrary
unzip -q $BUILDLOC/digilib-$DIGILIB_CHANGESET/webapp/target/digilib*.war

#mkdir $BUILDLOC/sade/images
mkdir images
mkdir scaled
mkdir thumb
sed -i 's/<parameter name="basedir-list" value="\/docuserver\/images:\/docuserver\/scaled\/small:\/docuserver\/scaled\/thumb" \/>/<parameter name="basedir-list" value="images:scaled:thumb" \/>/g' WEB-INF/digilib-config.xml

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
# deploy sade packages to exist
#
##
echo "[SADE BUILD] install and deploy sade packages"
echo "[SADE BUILD] starting sade"

$BUILDLOC/sade/bin/sade.sh start


# I have a fix for the following in my pipeline (waiting only as long
# as necessary)
sleep 20s
echo "[SADE BUILD] deploying SADE core packages"

cd $SCRIPTLOC/packages
ant -f localdeploy.xml

echo -e "[SADE BUILD] sade modules deploy done.\n"

####
#
#  don't kill running sade instance if requested with -r
##
if [ $KEEP_RUNNING != true ];then
	$BUILDLOC/sade/bin/sade.sh stop
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
    echo "[SADE BUILD] creating zipfile: $BUILDLOC/sade.zip"
    cd $BUILDLOC
    zip -rq sade.zip sade
fi

echo "[SADE BUILD] done"
echo "[SADE BUILD] you may now go to $BUILDLOC/sade and run 'bin/sade.sh start'"



