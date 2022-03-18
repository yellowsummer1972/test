#!/bin/bash

# this script is used to stress test gdpxl server
scriptdir=$(dirname `realpath $0`)
cd $scriptdir
shopt -s expand_aliases
mypid=$$

source ${scriptdir}/lib.sh


# config
procdir=${scriptdir}/proc
conf_path="${scriptdir}/pump.conf"
sites_list_path="${scriptdir}/sites.lst"

# thread
threadscript="${scriptdir}/thread.sh"
test -f $thread || { echo "Required script $thread does not exist. quit"; exit 1; }


# kill all process on startup
if [ -d "$procdir" ]; then 
	for fn in `ls -1 "$procdir"`; do 
    source ${procdir}/$fn
    kill -9 $mypid
    rm -f ${procdir}/$fn
    echo "Killed left over pid $mypid for url $targeturl"
  done

else
  mkdir -p "$procdir"
fi
test -d "$procdir" || { echo "Error: I could not create directory ${kdir}.  Quit."; exit 1; }




# loop to monitor threads
while true; do 
  
  # source the conf
  source $conf_path


	# if running is 0, we terminate all 
  if [[ $running -eq 0 ]]; then 
		echo "Termination order received.  Kill all threads".
    # kill all 
    for fn in `ls -1 $procdir`; do
			source ${procdir}/$fn && kill -9 $mypid
      echo "== Killed site $targeturl -  pid $mypid"
      rm -f ${procdir}/$fn
    done
		echo "All threads killed"
    sleep $refresh_site_list_timeout
    continue
  fi


  # we want to kill process running url not in the list
	for fn in `ls -1 $procdir`; do 
		source ${procdir}/$fn
    
    grep -q "^${targeturl}$" $sites_list_path
    if [[ $? -ne 0 ]]; then 
      # kill it
      source $fn && kill -9 $mypid
      rm -f ${procdir}/$fn
      echo "==Site $targeturl does not exist. Killed its thread (Pid $mypid)"
    fi
  done 


  # we want to create thread for sites that are newly added
   for line in `cat $sites_list_path | egrep -v '^#|^$' | tr '[:upper:]' '[:lower:]'`; do
    url=$(echo "$line" | tr -d '\n\r')

    procpath=$(findprocbyurl "$url"  "$procdir")
    if [ $? -eq 1 ]; then 
      # create thread here
      echo "==Create thread for ${url}"
      #nohup ${threadscript} $url > /dev/null 2>&1 &
      ${threadscript} ${url} &
      sleep 1
    fi
  done

  # loop
  sleep $refresh_site_list_timeout
done


