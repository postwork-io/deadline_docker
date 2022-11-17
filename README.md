# deadline_docker

## Description

This project is to get Deadline Render manager up and running quickly for small farms or testing.

## How to Use

### Running the Stack
Install docker and docker compose
Rename `example.env` to `.env` and update any of the password fields with secure passwords.
Navigate to an  the repo folder and run `docker-compose up` and it will download and build and start running.

### Connecting clients

Any files needed for client intallation will be hosted on the filebrowser server included in the stack. The server can be accessed at http://(hostname or ip address of the computer running docker compose):8080 . The default username and password will be `admin` and `admin`. Probably should change that. Once in in the folder `installers` will be a zip that contains client installers for different platforms. Submission installers for DCCs can either be downloaded through Deadline Monitor once that is installed or found in the Repo folder under submission.

During the installation of the client make sure to connect to the repository using the Remote Connection Server. The hostname is the hostname or IP address of the computer running docker compose. If using TLS to connect use the port defined in the .env file under `RCS_TLS_PORT` and make sure to download `Deadline10RemoteClient.pfx` from the filebrowser server and supply that as the certificate and supply the passphrase from the .env file for `RCS_CERT_PASS` as the password. If not using TLS disable the option and use the port defined in `RCS_HTTP_PORT` in the .env file.

## Environment Variable Guide

`DEADLINE_VERSION` The current version of deadline
`DEADLINE_INSTALLER_BASE` The basename for the deadline installer hosted on the Thinkbox S3 Bucket
`RCS_HTTP_PORT` Port used to connect to the Remote Connection Server if TLS is disabled
`RCS_TLS_PORT` Port used to connect to the Remote Connection Server if TLS is enabled 
`RCS_CERT_PASS` The passphrase used with the Remote Client Certificate used to connect to the Remote Connection Server
`DB_CERT_PASS` The passphrase used with deadline client certificate for servers to connect directly with the database
`SECRETS_USERNAME` Admin username used with the deadline secets manager
`SECRETS_PASSWORD` Password used for the deadline secrets manager. Must include lower case, upper case, numbers, and symbols
`ROOT_DOMAIN` Used to set the hostname of the container to a FQDN if using DNS
`CERT_ORG` Org for creating certificates
`CERT_OU` Organizational Unit for certificate creation
`DB_HOST` hostname for the database (probably don't need to change this)
`USE_RCS_TLS` Set to `TRUE` if want all communication with the Remote Connection Server to be encrypted (Required if using the secrets manager)
`USE_WEBSERVICE` Set to `TRUE` to start the deadline webservice server
`USE_LICENSE_FORWARDER` Set to `TRUE` if using the deadline license forwarder to use the Usage Based Licensing

## Backup and Restore

To backup the containers use the backup_volumes script from the scripts folder of the repo. 
`scripts/backup_volumes.bat`
By default it will create a .tar archive for each volume appended with the date in a YYYY-MM-DD format in the current working directroy. To specify a backup location supply the path as a command line variable.
`scripts/backup_volumes.bat Drive:/path/to/backup_folder`

To restore a backup first bring up the stack and wait for all the containers to be fully created and then bring the stack back down. Then run the restore_volumes script from the scripts folder of the repo.
`scripts/restore_volumes.bat`

If the backups aren't in the current directory or you want to restore a backup from a different date then the current day you can specify a path and date.
`scripts/backup_volumes.bat Drive:/path/to/backup_folder YYYY-MM-DD` 

Bring the stack up and all should be restored.
