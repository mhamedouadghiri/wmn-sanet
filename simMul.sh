#!/bin/bash

set -e

tcl="${1}.tcl"
tr="${1}.tr"
nb_simul=$(($2 - 1))
base_duration=$3
interval=$4

time="time = ["
newreno="newreno = ["
vegas="vegas = ["

for i in `seq 0 $nb_simul`
do
  current=$(($base_duration + $i * $interval))
  echo "------------------------------ start $current ------------------------------"
  
  ns $tcl $current &> /dev/null
  
  awkOut=$(awk -f awk.awk $tr)
  
  nr=$(sed -n 1p <<< $awkOut)
  v=$(sed -n 2p <<< $awkOut)

  echo "$current, $nr, $v"

  time+=$current
  newreno+=$nr
  vegas+=$v
  
  if [ $i -ne $nb_simul ]
  then
    time+=", "
    newreno+=", "
    vegas+=", "
  fi

  echo "------------------------------ end   $current ------------------------------"
done

time+="]"
newreno+="]"
vegas+="]"

echo "$time"
echo "$newreno"
echo "$vegas"

rm *.tr *.nam

