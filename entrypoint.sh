#! /bin/bash

echo Starting the SSH server
/usr/sbin/sshd -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start SSH server: $status"
  exit $status
else
  echo SSH server started successfully
fi

echo Making sure rethinkdb and api are up and responding...
while true
do
  rethinkdb_svc_status=$(nc -z rethinkdb 29015; echo $?)
  api_svc_status=$(nc -z api 8080; echo $?)
  if [ $rethinkdb_svc_status -ne 0 ] || [ $api_svc_status -ne 0 ]
  then
    echo "waiting for rethinkdb and api services to become available..."
    echo "sleeping for 5s..."
    sleep 5
  else
    break
  fi
done

echo "Starting apl-admin..."

exec python - <<-EOF
print "Running admin.main()"
from apl_admin import admin
admin.main()
EOF
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start apl_admin : $status"
  exit $status
else
  echo apl_admin server started successfully
fi

#Watching SSH processes and make sure its running
while /bin/true; do
  echo Probing SSH service...
  ps aux |grep sshd |grep -q -v grep
  PROCESS_SSH_STATUS=$?
  echo SSH server status: $PROCESS_SSH_STATUS
  if [ $PROCESS_SSH_STATUS -ne 0 ]; then
    echo "SSH processes is down, going to restart it."
    echo Starting the SSH server
    /usr/sbin/sshd -D
    status=$?
    if [ $status -ne 0 ]; then
     echo "Failed to start SSH server: $status"
     exit $status
    else
     echo SSH server started successfully
    fi
    echo SSH service has failed too many times, going to exit. Please check the logs...
    exit -1
  fi
  sleep 60
done