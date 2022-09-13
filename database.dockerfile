FROM ubuntu:18.04

ARG DB_CERT_PASS
ARG SECRETS_USERNAME
ARG SECRETS_PASSWORD
ARG DB_HOST
ARG DEADLINE_VERSION
ARG DEADLINE_INSTALLER
ARG CERT_ORG
ARG CERT_OU

WORKDIR /build

RUN apt-get update

RUN apt-get install -y curl &&\
    apt-get install -y python python-pip git dos2unix
RUN mkdir ~/keys

#Generate Certificates
RUN git clone https://github.com/ThinkboxSoftware/SSLGeneration.git &&\
    pip install pyopenssl==17.5.0

RUN python ./SSLGeneration/ssl_gen.py --ca --cert-org ${CERT_ORG} --cert-ou ${CERT_OU} --keys-dir ~/keys &&\
    python ./SSLGeneration/ssl_gen.py --server --cert-name ${DB_HOST} --alt-name localhost --alt-name 127.0.0.1 --keys-dir ~/keys &&\
    python ./SSLGeneration/ssl_gen.py --client --cert-name deadline-client --keys-dir ~/keys &&\
    python ./SSLGeneration/ssl_gen.py --pfx --cert-name deadline-client --keys-dir ~/keys --passphrase ${DB_CERT_PASS} &&\
    cat ~/keys/${DB_HOST}.crt ~/keys/${DB_HOST}.key > ~/keys/mongodb.pem


RUN mkdir /client_certs

#Install Database
RUN mkdir -p /opt/Thinkbox/DeadlineDatabase10/mongo/data &&\
 mkdir -p /opt/Thinkbox/DeadlineDatabase10/mongo/application &&\
 mkdir -p /opt/Thinkbox/DeadlineDatabase10/mongo/data/logs

COPY ./database_config/config.conf /opt/Thinkbox/DeadlineDatabase10/mongo/data/

RUN curl https://downloads.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1804-4.2.12.tgz -o mongodb-linux-x86_64-ubuntu1804-4.2.12.tgz 
RUN tar -xvf mongodb-linux-x86_64-ubuntu1804-4.2.12.tgz
RUN mv mongodb-linux-x86_64-ubuntu1804-4.2.12/bin /opt/Thinkbox/DeadlineDatabase10/mongo/application/
RUN rm mongodb-linux-x86_64-ubuntu1804-4.2.12.tgz && rm -rf mongodb-linux-x86_64-ubuntu1804-4.2.12


#Install Repository
#COPY ./Deadline-${DEADLINE_VERSION}-linux-installers.tar ./Deadline-${DEADLINE_VERSION}-linux-installers.tar
RUN curl -L ${DEADLINE_INSTALLER} -o Deadline-${DEADLINE_VERSION}-linux-installers.tar
RUN tar -xvf Deadline-${DEADLINE_VERSION}-linux-installers.tar

# Start the databse and then setup the initial database settings
RUN nohup bash -c "/opt/Thinkbox/DeadlineDatabase10/mongo/application/bin/mongod\
    --config /opt/Thinkbox/DeadlineDatabase10/mongo/data/config.conf &" &&\
    sleep 4 &&\
    ./DeadlineRepository-${DEADLINE_VERSION}-linux-x64-installer.run --mode unattended \
    --dbhost 127.0.0.1\
    --dbport 27100\
    --installSecretsManagement true\
    --secretsAdminName ${SECRETS_USERNAME}\
    --secretsAdminPassword ${SECRETS_PASSWORD}\
    --installmongodb false\
    --prefix /repo\
    --dbname deadline10db\
    --dbclientcert ~/keys/deadline-client.pfx\
    --dbcertpass ${DB_CERT_PASS}\
    --dbssl true

RUN sed -i "s/127.0.0.1/${DB_HOST}/g" /repo/settings/connection.ini

RUN rm Deadline-${DEADLINE_VERSION}-linux-installers.tar &&\
    rm -rf ./Deadline-${DEADLINE_VERSION}-linux-installers

ADD ./database_entrypoint.sh .
RUN dos2unix ./database_entrypoint.sh && chmod u+x ./database_entrypoint.sh

ENTRYPOINT [ "./database_entrypoint.sh" ]
