#!/bin/bash

cp ~/keys/deadline-client.pfx /client_certs/deadline-client.pfx

/opt/Thinkbox/DeadlineDatabase10/mongo/application/bin/mongod --config /opt/Thinkbox/DeadlineDatabase10/mongo/data/config.conf