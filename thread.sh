#!/bin/bash

scriptdir=$(dirname `realpath $0`)
cd $scriptdir


conf_path=${scriptdir}/pump.conf
procdir=${scriptdir}/proc

source ${scriptdir}/lib.sh
source ${conf_path}

test $# -ne 1 && { 
  echo "Script needs exactly 1 argument 'url'. exit"; 
  echo "example: $0 google.com https"
  exit 1; 
}

# target url - should be fully formed with protocol
target_url="$1"


# create proc file 
procfile="${procdir}/$(url2str $target_url)"
if [ -f "$procfile" ]; then
  # kill the existing process 
  source $procfile
  kill -9 $mypid
  sleep 5
  rm -f ${procfile}
fi
mypid=$$
echo "mypid='$mypid'" > $procfile
echo "targeturl='$target_url'" >> $procfile
echo "Proc file $procfle created for url $target_url"



# return 0 if website is reachable (200 or 300)
# return 1 if 400 or 500
function is_reachable()
{
  res=$(curl --connect-timeout 5 -ksI $target_url | head -1)
  rescode=$(echo "$res" | awk '{print $2}')

  if [ -z "$res" ]; then 
    return 1
  elif [[ $rescode -ge 200 ]] && [[ $rescode -lt 399 ]]; then 
    return 0
  else
    return 1;
  fi 
}

while true; do
  source ${conf_path}
  is_reachable $target_url
  code=$?

  if [ $code -eq 0 ]; then 
    # site is reachable
    pumprequests "$target_url"  $burst_count
  else
    # site is not reachable
    echo "site $target_url is unresponsive. Wait $wait_before_retry secs before retry"
    sleep $wait_before_retry
  fi
done


