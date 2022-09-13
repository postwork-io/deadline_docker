FROM ubuntu:18.04

ARG DEADLINE_VERSION
ARG DEADLINE_INSTALLER

WORKDIR /build

RUN mkdir ~/certs


RUN apt-get update && apt-get install -y lsb curl && apt-get install -y dos2unix

#Only copy if it exists locally in the environment
#COPY ./Deadline-${DEADLINE_VERSION}-linux-installers.tar ./Deadline-${DEADLINE_VERSION}-linux-installers.tar
RUN curl -L ${DEADLINE_INSTALLER} -o Deadline-${DEADLINE_VERSION}-linux-installers.tar
RUN tar -xvf Deadline-${DEADLINE_VERSION}-linux-installers.tar

ADD ./client_entrypoint.sh .
RUN dos2unix ./client_entrypoint.sh && chmod u+x ./client_entrypoint.sh


ENTRYPOINT [ "./client_entrypoint.sh" ]
