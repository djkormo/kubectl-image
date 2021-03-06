#!/bin/bash
. /provisioners/functions
func_initialize_check_force_update

func_initialize $PROV_TYPE $NS_DIR


cleanup ()
{
  kill -s SIGTERM $!
  exit 0
}
trap cleanup SIGINT SIGTERM

while [ 1 ]
do
  sleep $[ ( $RANDOM % 20 )  + 1 ]s &
  wait $!

  if ( set -o noclobber; echo $PROV_TYPE > "$lockfile") 2> /dev/null; then
    trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

    func_apply_on_changed_files $NS_DIR

    # clean up after yourself, and release your trap
    rm -f "$lockfile"
    trap - INT TERM EXIT
  else
    date=$(date -I'seconds')
    echo "$date Lock Exists: $lockfile owned by $(cat $lockfile)"
  fi

done
