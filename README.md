App Dev Cloud with JBoss Cool Store Persistence Demo 
==========================================
This demo is to install JBoss Cool Store in the Cloud with PostgreSQL data persistence based on leveraging the Red Hat Container Development Kit (CDK) and the
provided OpenShift Enterprise (OSE) image. It delivers a fully functioning JBoss Cool Store containerized on OSE and backed by a persistent data store.

The Cool Store is a retail web store demo where you will find rules, decision tables, events, and a ruleflow 
that is leveraged by a web application. The web application is a WAR built using the JBoss BRMS
generated project as a dependency, providing an example project showing how developers can focus on the 
application code while the business analysts can focus on rules, events, and ruleflows in the 
JBoss BRMS product web based dashboard.

Alongside the Cool Store is a PostgreSQL database container that provides persistent storage for the JBoss BRMS platform and connected via Kubernetes services.

This demo environment is fully containerized, it uses a custom maven settings to deploy all built JBoss BRMS knowledge artifacts
into an external maven repository (not your local repository), in /tmp/maven-repo.


Install on Red Hat CDK OpenShift Enterprise image
-------------------------------------------------
1. First complete the installation and start the OpenShift image supplied in the [cdk-install-demo](https://github.com/redhatdemocentral/cdk-install-demo).

2. Install [OpenShift Client Tools](https://developers.openshift.com/managing-your-applications/client-tools.html) if you have not done so previously.

3. [Download and unzip this demo.](https://github.com/redhatdemocentral/rhcs-coolstore-persistence-demo/archive/master.zip)

4. Add products to installs directory.

5. Run 'init.sh' or 'init.bat' file. 'init.bat' must be run with Administrative privileges.

6. Login to Cool Store to start exploring a retail web shopping project:

    [http://rhcs-coolstore-p-demo.10.1.2.2.xip.io/business-central](http://rhcs-coolstore-p-demo.10.1.2.2.xip.io/business-central)
    ( u:erics / p:jbossbrms1! )

    [http://rhcs-coolstore-p-demo.10.1.2.2.xip.io/brms-coolstore-demo](http://rhcs-coolstore-p-demo.10.1.2.2.xip.io/brms-coolstore-demo)


Note before running demo:
-------------------------
The web application (shopping cart) is built during demo installation with a provided coolstore project jar version 2.0.0. When you 
open the project you will find the version is also set to 2.0.0. You can run the web application as is, but if you build and deploy
a new version of 2.0.0 to your maven repository it will find duplicate rules. To demo you deploy a new version of the coolstore
project by bumping the version number on each build and deploy, noting the KieScanner picking up the new version within 10 seconds 
of a new deployment. For example, initially start project, bump the version to 3.0.0, build and deploy, open web application and
watch KieScanner in server logs pick up the 3.0.0 version. Now change a shipping rule value in decision table, save, bump project
version to 4.0.0, build and deploy, watch for KieScanner picking up new 4.0.0 version, now web application on next run will use new
shipping values.


Tip & Trick
-----------
This is a good way to look at what is being created during the installation:

    ```
    $ oc get all

    NAME                            TYPE                                                            FROM                  LATEST
    rhcs-coolstore-p-demo           Docker                                                          Binary                1
    NAME                            TYPE                                                            FROM                  STATUS     STARTED       DURATION
    rhcs-coolstore-p-demo-1         Docker                                                          Binary                Complete   2 hours ago   12m43s
    NAME                            DOCKER REPO                                                     TAGS                  UPDATED
    developer                       jbossdemocentral/developer                                      latest,1.0,jdk8-uid   2 hours ago
    rhcs-coolstore-p-demo           172.30.19.20:5000/rhcs-coolstore-p-demo/rhcs-coolstore-p-demo   latest                2 hours ago
    NAME                            TRIGGERS                                                        LATEST
    postgresql                      ConfigChange, ImageChange                                       1
    rhcs-coolstore-p-demo           ConfigChange, ImageChange                                       2
    CONTROLLER                      CONTAINER(S)                                                    IMAGE(S)                                                                                                                                SELECTOR                                                                                              REPLICAS                                                           AGE
    postgresql-1                    postgresql                                                      registry.access.redhat.com/rhscl/postgresql-94-rhel7:latest                                                                             deployment=postgresql-1,deploymentconfig=postgresql,name=postgresql                                   1                                                                  2h
    rhcs-coolstore-p-demo-1         rhcs-coolstore-p-demo                                           172.30.19.20:5000/rhcs-coolstore-p-demo/rhcs-coolstore-p-demo@sha256:ec3ae77857a0dca7035ac29218d5fd7d433085d25920d3fdcb20d3379ff00f92   app=rhcs-coolstore-p-demo,deployment=rhcs-coolstore-p-demo-1,deploymentconfig=rhcs-coolstore-p-demo   0                                                                  2h
    rhcs-coolstore-p-demo-2         rhcs-coolstore-p-demo                                           172.30.19.20:5000/rhcs-coolstore-p-demo/rhcs-coolstore-p-demo@sha256:ec3ae77857a0dca7035ac29218d5fd7d433085d25920d3fdcb20d3379ff00f92   app=rhcs-coolstore-p-demo,deployment=rhcs-coolstore-p-demo-2,deploymentconfig=rhcs-coolstore-p-demo   1                                                                  2h
    NAME                            HOST/PORT                                                       PATH                                                                                                                                    SERVICE                                                                                               LABELS                                                             INSECURE POLICY   TLS TERMINATION
    rhcs-coolstore-p-demo           rhcs-coolstore-p-demo.10.1.2.2.xip.io                                                                                                                                                                   rhcs-coolstore-p-demo                                                                                 app=rhcs-coolstore-p-demo                                                            
    NAME                            CLUSTER_IP                                                      EXTERNAL_IP                                                                                                                             PORT(S)                                                                                               SELECTOR                                                           AGE
    postgresql                      172.30.71.80                                                    <none>                                                                                                                                  5432/TCP                                                                                              name=postgresql                                                    2h
    rhcs-coolstore-p-demo           172.30.127.106                                                  <none>                                                                                                                                  8080/TCP,9990/TCP,9999/TCP                                                                            app=rhcs-coolstore-p-demo,deploymentconfig=rhcs-coolstore-p-demo   2h
    NAME                            READY                                                           STATUS                                                                                                                                  RESTARTS                                                                                              AGE
    postgresql-1-7fbdh              1/1                                                             Running                                                                                                                                 0                                                                                                     2h
    rhcs-coolstore-p-demo-1-build   0/1                                                             Completed                                                                                                                               0                                                                                                     2h
    rhcs-coolstore-p-demo-2-knzxf   1/1                                                             Running                                                                                                                                 0                                                                                                     2h


Supporting Articles
-------------------
- [Ultimate Cloud Guide to Retail in the Cloud with JBoss Cool Store](http://www.schabell.org/2016/03/ultimate-cloud-guide-retail-cloud-jboss-coolstore.html)


Released versions
-----------------

![OSE pod](https://github.com/redhatdemocentral/rhcs-coolstore-persistence-demo/blob/master/docs/demo-images/rhcs-coolstore-p-pod.png?raw=true)

![OSE build](https://github.com/redhatdemocentral/rhcs-coolstore-persistence-demo/blob/master/docs/demo-images/rhcs-coolstore-p-build.png?raw=true)

![JBoss BRMS](https://github.com/redhatdemocentral/rhcs-coolstore-persistence-demo/blob/master/docs/demo-images/jboss-brms.png?raw=true)

![Decision Table](https://github.com/redhatdemocentral/rhcs-coolstore-persistence-demo/blob/master/docs/demo-images/coolstore-decision-table.png?raw=true)

