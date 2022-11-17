
IF [%1]==[] (
    set output_path=%cd%
) ELSE (
    set output_path=%1
)

IF [%2]==[] (
    set current_date=%date:~10,4%-%date:~4,2%-%date:~7,2%
) ELSE (
    set current_date=%2
)

docker run --rm --volume deadline_docker_db_data:/data --volume %output_path%:/backup ubuntu tar xvf /backup/deadline_docker_db_%current_date%.tar
docker run --rm --volume deadline_docker_certs:/data --volume %output_path%:/backup ubuntu tar xvf /backup/deadline_docker_certs_%current_date%.tar
docker run --rm --volume deadline_docker_repo:/data --volume %output_path%:/backup ubuntu tar xvf /backup/deadline_docker_repo_%current_date%.tar
docker run --rm --volume deadline_docker_server_certs:/data --volume %output_path%:/backup ubuntu tar xvf /backup/deadline_docker_server_certs_%current_date%.tar