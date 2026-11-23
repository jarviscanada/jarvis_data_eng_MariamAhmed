#! /bin/bash

# assign CLI arguements to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# save current machine hostname to variable
hostname=$(hostname -f)

lscpu_out=$(lscpu)

# parse host hardware specs using bash cmds
# xargs is a trick to trim leading and trailing whitespaces
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | sed 's/^Model name:[[:space:]]*//')
cpu_mhz=$(grep -m1 "cpu MHz" /proc/cpuinfo | awk '{print $4}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep  "^L2 cache:" | awk '{print $3}' | sed 's/[^0-9]//g')
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs)
timestamp=$(date --utc +"%Y-%m-%d %H:%M:%S")

# insert data into host_info table

insert_stmt="INSERT INTO host_info
  (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem)
VALUES
  ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# execute through psql CLI

export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"
exit $?




