##########################
# Sampath Kunapareddy    #
# sampath.a926@gmail.com #
##########################
#!/bin/bash
#set -x

COMMAND() {
  nc -zv -w3 $1 $2 &>/dev/null
  #telnet $1 $2 &>/dev/null
}

removeres() {
  rm iptest &>/dev/null
  rm porttest &>/dev/null
}

if [[ $# -eq 2 ]]; then
  removeres
  if [ -f $1 ] && [ -f $2 ]; then
    if [[ $(cat $1 | tr ',' '\n' | wc -l) -ne $(cat $2 | tr ',' '\n' | wc -l) ]] &>/dev/null; then
      echo -e "\nMismatch in IPs and PORTs count, please check....\n"; exit 1
    fi
  elif [ ! -f $1 ] && [ ! -f $2 ]; then
    if [[ $(echo $1 | tr ',' '\n' | wc -l) -ne $(echo $2 | tr ',' '\n' | wc -l) ]] &>/dev/null; then
      echo -e "\nMismatch in IPs and PORTs count, please check....\n"; exit 1
    fi
  else
    echo -e "\nPlease provide IPs/PORTs as comma sepearted (or) as files..\n"; exit 1
  fi
  if [[ -f $1 ]]; then ipUSE=$(cat $1|tr '\n' ','); else echo "$1" >| iptest; ipUSE=$(cat iptest); fi
  if [[ -f $2 ]]; then portUSE=$(cat $2|tr '\n' ','); else echo "$2" >| porttest; portUSE=$(cat porttest); fi
  count=1
  read -p "Need results in a file (y/n):" yn
  if [[ "$yn" == [Yy]* ]]; then
    RESULTS=results_`date +"%m-%d-%Y-%H"`.txt
    >|$RESULTS
    echo -e "\n\nResults are written into \"$RESULTS\" file....."
  fi
  echo -e "\n"
  for eachip in `echo ${ipUSE} | tr ',' '\n'`; do
    IP=$eachip
    PORT=$(echo ${portUSE} | tr ',' '\n' | head -$count | tail -1)
    echo "working on \"IP:$IP over PORT:$PORT\" please wait...."
    #PING=$(ping -q -c 1 -W 1 $IP | tail -2 | head -1 | awk -F , '{print $3}')
    PINGR=$(echo PING:  `ping -q -c 1 -W 1 $IP 2>/dev/null | tail -2 | head -1 | awk -F , '{print $3}' | awk '{print $1" "$2$3}'`)
    COMMAND $IP $PORT
      if [[ `echo $?` -eq 0 ]]; then
        echo "$PINGR - $IP $PORT - SUCCESS" | tee -a $RESULTS
        echo ""
      else
        echo "$PINGR - $IP $PORT - UNsuccess" | tee -a $RESULTS
        echo ""
      fi
    ((count++))
  done
else
  clear
  echo -e "\n"
  echo -e "\tUSAGE: $0 \e[1mIP(single) PORT(single)\e[0m  or\n\t\t ex: $0 1.1.1.1 111"
  echo -e "\tUSAGE: $0 \e[1mIPs(comma seperated) PORTs(comma seperated)\e[0m  or\n\t\t ex: $0 1.1.1.1,2.2.2.2 111,222"
  echo -e "\tUSAGE: $0 \e[1mIPs-list(file) PORTs-list(file)\e[0m  or\n\t\t ex: $0 ips.txt ports.txt"
  echo -e "\n"
fi
removeres
