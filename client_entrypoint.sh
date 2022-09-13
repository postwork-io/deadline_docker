#!/bin/bash



RCS_BIN=/opt/Thinkbox/Deadline10/bin/deadlinercs
WEB_BIN=/opt/Thinkbox/Deadline10/bin/deadlinewebservice
WORKER_BIN=/opt/Thinkbox/Deadline10/bin/deadlineworker
FORWARDER_BIN=/opt/Thinkbox/Deadline10/bin/deadlinelicenseforwarder
DEADLINE_CMD=/opt/Thinkbox/Deadline10/bin/deadlinecommand

configure_from_env () {
    if [[ -z "$DEADLINE_REGION" ]]; then
        $DEADLINE_CMD SetIniFileSetting Region $DEADLINE_REGION
    fi
}

if [ "$1" == "rcs" ]; then
    echo "Deadline Remote Connection Server"
    if [ -e "$RCS_BIN" ]; then

        /bin/bash -c "$RCS_BIN"
    else

        echo "Initializing Remote Connection Server"
        /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run \
        --mode unattended \
        --enable-components proxyconfig \
        --repositorydir /repo \
        --dbsslcertificate /client_certs/deadline-client.pfx \
        --dbsslpassword $DB_CERT_PASS \
        --noguimode true \
        --slavestartup false \
        --httpport $RCS_HTTP_PORT \
        --tlsport $RCS_TLS_PORT \
        --enabletls true \
        --tlscertificates generate \
        --generatedcertdir ~/certs \
        --clientcert_pass $RCS_CERT_PASS \
        --InitializeSecretsManagementServer true \
        --secretsAdminName $SECRETS_USERNAME \
        --secretsAdminPassword $SECRETS_PASSWORD \
        --masterKeyName defaultKey \
        --osUsername root

        cp /root/certs/Deadline10RemoteClient.pfx /client_certs/Deadline10RemoteClient.pfx
        rm  /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run
        "$DEADLINE_CMD" secrets ConfigureServerMachine "$SECRETS_USERNAME" defaultKey root --password env:SECRETS_PASSWORD

        "$RCS_BIN"
    fi
elif [ "$1" == "webservice" ]; then
    if [ -e "$WEB_BIN" ]; then
        /bin/bash -c "$WEB_BIN"
    else
        echo "Initializing Deadline Webservice"
        /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run \
        --mode unattended \
        --enable-components webservice_config \
        --repositorydir /repo \
        --dbsslcertificate /client_certs/deadline-client.pfx \
        --dbsslpassword $DB_CERT_PASS \
        --noguimode true \
        --slavestartup false \
        --webservice_enabletls false

        rm  /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run

        "$WEB_BIN"
    fi

elif [ "$1" == "worker" ]; then
    echo "not yet implemented"

elif [ "$1" == "forwarder" ]; then
    if [ -e "$FORWARDER_BIN" ]; then
        /bin/bash -c "$FORWARDER_BIN"
    else
        echo "Initializing License Forwarder"
        /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run \
        --mode unattended \
        --repositorydir /repo \
        --dbsslcertificate /client_certs/deadline-client.pfx \
        --dbsslpassword $DB_CERT_PASS \
        --noguimode true \
        --slavestartup false \
        --secretsAdminName $SECRETS_USERNAME \
        --secretsAdminPassword $SECRETS_PASSWORD \

        rm  /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run

        "$FORWARDER_BIN" -sslpath /client_certs
    fi
elif [ "$1" == "zt-forwarder" ]; then
    if [ -e "$FORWARDER_BIN" ]; then
        /usr/sbin/zerotier-one -d
        /bin/bash -c "$FORWARDER_BIN"
    else
        echo "Initializing ZT License Forwarder"
        /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run \
        --mode unattended \
        --repositorydir /repo \
        --dbsslcertificate /client_certs/deadline-client.pfx \
        --dbsslpassword $DB_CERT_PASS \
        --noguimode true \
        --slavestartup false \
        --secretsAdminName $SECRETS_USERNAME \
        --secretsAdminPassword $SECRETS_PASSWORD \

        rm  /build/DeadlineClient-$DEADLINE_VERSION-linux-x64-installer.run
        
        curl -s https://install.zerotier.com | /bin/bash
        echo 9994 > /var/lib/zerotier-one/zerotier-one.port
        chmod 0600 /var/lib/zerotier-one/zerotier-one.port
        /usr/sbin/zerotier-one -d
        sleep 5
        /usr/sbin/zerotier-cli status
        /usr/sbin/zerotier-cli join $ZT_NETWORK_ID

        "$FORWARDER_BIN" -sslpath /client_certs
    fi
else
    /bin/bash 
fi
