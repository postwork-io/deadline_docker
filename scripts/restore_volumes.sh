#!/bin/bash

current_date=$(date -I)

if [ $1 == "" ]; then
    output_path=$PWD
else
    output_path=$1
fi

if [ $2 == "" ]; then
    current_date=$(date -I)
else
    current_date=$2
fi

docker run --rm --volume deadline_docker_db_data:/data --volume $output_path:/backup ubuntu tar xvf /backup/deadline_docker_db_$current_date.tar
docker run --rm --volume deadline_docker_certs:/data --volume $output_path:/backup ubuntu tar xvf /backup/deadline_docker_certs_$current_date.tar
docker run --rm --volume deadline_docker_repo:/data --volume $output_path:/backup ubuntu tar xvf /backup/deadline_docker_repo_$current_date.tar
docker run --rm --volume deadline_docker_server_certs:/data --volume $output_path:/backup ubuntu tar xvf /backup/deadline_docker_server_certs_$current_date.tar
#docker run --rm --volume deadline_docker_installers:/data --volume $output_path:/backup ubuntu tar xvf /backup/deadline_docker_installers_$current_date.tar