#!/bin/bash
while :
do
	for (( c=1; c<=$((1 + $RANDOM % 50)); c++ ))
  do  
    curl -s -X GET "http://10.0.0.12:8080/quote" > /dev/null
  done

  curl -s -X GET "http://10.0.0.12:8080/quote?slow=true" > /dev/null

  for (( c=1; c<=$((1 + $RANDOM % 30)); c++ ))
  do  
    curl -s -X GET "http://10.0.0.12:8081/quote" > /dev/null
  done

  curl -s -X GET "http://10.0.0.12:8081/quote?slow=true" > /dev/null

done
