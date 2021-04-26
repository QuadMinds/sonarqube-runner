#!/usr/bin/env bash

# max_retry=5
# counter=0
# until $command
# do
#  sleep 1
#  [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
#  echo "Trying again. Try #$counter"
#  ((counter++))
# done

# max_retry=5
# counter=0
# while [ counter -eq $max_retry ] and ! wget -qO- http://localhost:9999/api/system/status | grep -q -e '"status":"UP"' -e '"status":"DB_MIGRATION_NEEDED"' -e '"status":"DB_MIGRATION_RUNNING"'; do
#     (counter++)
#     sleep 1
# done

attempt_counter=0
max_attempts=100

until $(wget -qO- http://localhost:9999/api/system/status | grep -q -e '"status":"UP"' -e '"status":"DB_MIGRATION_NEEDED"' -e '"status":"DB_MIGRATION_RUNNING"'); do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
      printf "Max attempts reached"
      exit 1
    fi

    # printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 1
done