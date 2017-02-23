#!/bin/sh 
DEMO="Cloud JBoss Cool Store Persistence Demo"
AUTHORS="Andrew Block, Eric D. Schabell"
PROJECT="git@github.com:redhatdemocentral/rhcs-coolstore-persistence-demo.git"
SRC_DIR=./installs
SUPPORT_DIR=./support
OPENSHIFT_USER=openshift-dev
OPENSHIFT_PWD=devel
BRMS=jboss-brms-6.4.0.GA-deployable-eap7.x.zip
EAP=jboss-eap-7.0.0-installer.jar

# prints the documentation for this script.
function print_docs() 
{
	echo "This project can be installed on any OpenShift platform, such as OpenShift Container"
  echo "Platform (OCP). It is possible to install it on any available installation, just point"
	echo "this installer at your installation by passing an IP of your OpenShift installation:"
	echo
	echo "   $ ./init.sh IP"
	echo
	echo "If using Red Hat OCP, IP should look like: 192.168.99.100"
	echo
}

# check for a valid passed IP address.
function valid_ip()
{
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi

	return $stat
}

# wipe screen.
clear 

echo
echo "############################################################################"
echo "##                                                                        ##"   
echo "##  Setting up the ${DEMO}                ##"
echo "##                                                                        ##"   
echo "##                                                                        ##"   
echo "##   ####  ###   ###  #      #### #####  ###   ###  #####                 ##"
echo "##  #     #   # #   # #     #       #   #   # #   # #                     ##"
echo "##  #     #   # #   # #      ###    #   #   # ####  ###                   ##"
echo "##  #     #   # #   # #         #   #   #   # #  #  #                     ##"
echo "##   ####  ###   ###  ##### ####    #    ###  #   # #####                 ##"
echo "##                                                                        ##"   
echo "##                #####          ###   #### #####                         ##"
echo "##           #    #   #     #   #   # #     #                             ##"
echo "##          ###   #####    ###  #   #  ###  ###                           ##"
echo "##           #    #         #   #   #     # #                             ##"
echo "##                #              ###  ####  #####                         ##"
echo "##                                                                        ##"   
echo "##  brought to you by,                                                    ##"   
echo "##             ${AUTHORS}                             ##"
echo "##                                                                        ##"   
echo "##  ${PROJECT}  ##"
echo "##                                                                        ##"   
echo "############################################################################"
echo

# validate OpenShift host IP.
if [ $# -eq 1 ]; then
	if valid_ip $1; then
		echo "OpenShift host given is a valid IP..."
		HOST_IP=$1
		echo
		echo "Proceeding wiht OpenShift host: $HOST_IP..."
		echo
	else
		# bad argument passed.
		echo "Please provide a valid IP that points to an OpenShift installation..."
		echo
		print_docs
		echo
		exit
	fi
elif [ $# -gt 1 ]; then
	print_docs
	echo
	exit
else
	# no arguments, prodeed with default host.
	print_docs
	echo
	exit
fi

# make some checks first before proceeding.	
command -v oc -v >/dev/null 2>&1 || { echo >&2 "OpenShift command line tooling is required but not installed yet... download here: https://access.redhat.com/downloads/content/290"; exit 1; }

if [ -r $SRC_DIR/$EAP ] || [ -L $SRC_DIR/$EAP ]; then
	echo Product EAP sources are present...
	echo
else
	echo Need to download $EAP package from https://developers.redhat.com/products/eap/download
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

if [ -r $SRC_DIR/$BRMS ] || [ -L $SRC_DIR/$BRMS ]; then
	echo JBoss BRMS product sources are present...
	echo
else
	echo Need to download $BRMS package from https://developers.redhat.com/products/brms/download
	echo and place it in the $SRC_DIR directory to proceed...
	exit
fi

echo "OpenShift commandline tooling is installed..."
echo 
echo "Logging in to OpenShift as $OPENSHIFT_USER..."
echo
oc login $HOST_IP:8443 --password=$OPENSHIFT_PWD --username=$OPENSHIFT_USER

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc login' command!
	exit
fi

echo
echo "Creating a new project..."
echo
oc new-project app-dev-on-cloud-suite

echo
echo "Creating PostgreSQL Template..."
echo
oc create -f "${SUPPORT_DIR}/postgresql-ephemeral-template.json"

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc create' template command!
	exit
fi

echo
echo "Creating PostgreSQL Database..."
echo
oc new-app --template=postgresql-ephemeral -p POSTGRESQL_USER=brms -p POSTGRESQL_PASSWORD=brms -p POSTGRESQL_DATABASE=brms

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc new-app postgresql' command!
	exit
fi

echo
echo "Setting up a new build..."
echo
oc new-build "jbossdemocentral/developer" --name=rhcs-coolstore-p-demo --binary=true

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc new-build' command!
	exit
fi

# need to wait a bit for new build to finish with developer image.
sleep 10 

echo
echo "Importing developer image..."
echo
oc import-image developer

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc import-image' command!
	exit
fi

echo
echo "Starting a build, this takes some time to upload all of the product sources for build..."
echo
oc start-build rhcs-coolstore-p-demo --from-dir=. --follow=true --wait=true

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc start-build' command!
	exit
fi

echo
echo "Creating a new application..."
echo
oc new-app rhcs-coolstore-p-demo

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc new-app' command!
	exit
fi

echo
echo "Setting PostgreSQL Environments for BRMS..."
echo
oc env dc rhcs-coolstore-p-demo -e POSTGRESQL_DB_USER=brms -e POSTGRESQL_DB_PASSWORD=brms -e POSTGRESQL_DB_NAME=brms

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc env' command!
	exit
fi

echo
echo "Creating an externally facing route by exposing a service..."
echo
oc expose service rhcs-coolstore-p-demo --hostname=rhcs-coolstore-p-demo.$HOST_IP.xip.io

if [ $? -ne 0 ]; then
	echo
	echo Error occurred during 'oc expose service' command!
	exit
fi

echo
echo "=========================================================================="
echo "=                                                                        ="
echo "=  Login to start exploring the Cool Store Persistenceproject:           ="
echo "=                                                                        ="
echo "=  http://rhcs-coolstore-p-demo.$HOST_IP.xip.io/business-central  ="
echo "=                                                                        ="
echo "=    [ u:erics / p:jbossbrms1! ]                                         ="
echo "=                                                                        ="
echo "=                                                                        ="
echo "=  Access the Cool Store web shopping cart at:                           ="
echo "=                                                                        ="
echo "=    http://rhcs-coolstore-p-demo.$HOST_IP.xip.io/brms-coolstore-demo  ="
echo "=                                                                        ="
echo "=  Note: it takes a few minutes to expose the service...                 ="
echo "=                                                                        ="
echo "=========================================================================="

