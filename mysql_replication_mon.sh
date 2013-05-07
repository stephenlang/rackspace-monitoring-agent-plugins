#!/usr/bin/env bash
#
# mysql_replication_mon.sh
# Rackspace Cloud Monitoring Plugin to help detect if there are
# problems with MySQL Master / Slave replication.
#
# Copyright (c) 2013, Stephen Lang
# All rights reserved.
#
# Git repository available at:
# https://github.com/stephenlang/rackspace-monitoring-agent-plugins
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Curl Command:
# curl -i -X POST -H 'Host: monitoring.api.rackspacecloud.com' -H
# 'Accept-Encoding: gzip,deflate' -H 'X-Auth-Token: YOUR_API_TOKEN'
# -H 'Content-Type: application/json; charset=UTF-8' -H 'Accept: application/json'
# --data-binary '{"label": "MySQL Replication Check", "type": "agent.plugin", "details":
# {"args": ["none"],"file": "mysql_replication_mon.sh"}}'  --compress
# 'https://monitoring.api.rackspacecloud.com:443/v1.0/YOUR_ACCOUNT/entities/YOUR_ENTITY/checks'
#
# Usage:
# Place plug-in in /usr/lib/rackspace-monitoring-agent/plugins
#
# The following is an example 'criteria' for a Rackspace Monitoring Alarm:
#
# if (metric['slave_io_running'] == No) {
# return new AlarmStatus(CRITICAL, 'Replication LOG IO thread not running');
# }
# if (metric['slave_sql_running'] == No) {
# return new AlarmStatus(CRITICAL, 'Replication SQL thread not running.');
# }
# if (metric['seconds_behind_master'] > 300) {
# return new AlarmStatus(CRITICAL, 'Replication is more then 5 minutes behind master.');
# }
# if (metric['check_error'] == true) {
# return new AlarmStatus(CRITICAL, 'Replication is not configured or you do not have the required access to MySQL');
# }
# 
# return new AlarmStatus(OK, 'Replication Normal.');


# Logging Metrics - Linux

if [ `uname` = Linux ]; then

slave_io_running=`/usr/bin/mysql -Bse "show slave status\G" | grep Slave_IO_Running | awk '{ print $2 }'`
slave_sql_running=`/usr/bin/mysql -Bse "show slave status\G" | grep Slave_SQL_Running | awk '{ print $2 }'`
last_error=`/usr/bin/mysql -Bse "show slave status\G" | grep Last_error | awk -F \: '{ print $2 }'`
seconds_behind_master=`/usr/bin/mysql -Bse "show slave status\G" | grep Seconds_Behind_Master | awk -F \: '{ print $2 }'`

# Logging Metrics - FreeBSD

elif [ `uname` = FreeBSD ]; then

slave_io_running=`/usr/local/bin/mysql -Bse "show slave status\G" | grep Slave_IO_Running | awk '{ print $2 }'`
slave_sql_running=`/usr/local/bin/mysql -Bse "show slave status\G" | grep Slave_SQL_Running | awk '{ print $2 }'`
last_error=`/usr/local/bin/mysql -Bse "show slave status\G" | grep Last_error | awk -F \: '{ print $2 }'`
seconds_behind_master=`/usr/local/bin/mysql -Bse "show slave status\G" | grep Seconds_Behind_Master | awk -F \: '{ print $2 }'`

else
        echo "Cannot detect OS version!  Exit"
        exit
fi


# Check to see if replication is configured, or if we can access MySQL

if [ -z $slave_io_running -o -z $slave_sql_running ] ; then
	check_error=true
else
	check_error=false
fi

echo "metric check_error int $check_error"
echo "metric slave_io_running int $slave_io_running"
echo "metric slave_sql_running int $slave_sql_running"
echo "metric last_error int $last_error"
echo "metric seconds_behind_master int $seconds_behind_master"
