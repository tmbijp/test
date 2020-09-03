#!/bin/bash
#echo "test"
#echo "#TEST"

echo -n "try push? [N/y]:"
read input
if [ "$input" = "Y" ] || [ "$input" = "y" ];then
  echo 'input is "YES"'
else
  echo 'input is not "YES"'
fi

