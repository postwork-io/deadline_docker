#!/bin/bash

current_date=$(date -I)

if [ $1 == "" ]; then
    output_path=$PWD
else
    output_path=$1
fi

docker run --rm --volume deadline_docker_db_data:/data --volume $output_path:/backup ubuntu tar cvf /backup/deadline_docker_db_$current_date.tar /data
docker run --rm --volume deadline_docker_certs:/data --volume $output_path:/backup ubuntu tar cvf /backup/deadline_docker_certs_$current_date.tar  --exclude=*deadline-client.pfx /data
docker run --rm --volume deadline_docker_repo:/data --volume $output_path:/backup ubuntu tar cvf /backup/deadline_docker_repo_$current_date.tar /data
docker run --rm --volume deadline_docker_server_certs:/data --volume $output_path:/backup ubuntu tar cvf /backup/deadline_docker_server_certs_$current_date.tar /data
#docker run --rm --volume deadline_docker_installers:/data --volume $output_path:/backup ubuntu tar cvf /backup/deadline_docker_installers_$current_date.tar /data