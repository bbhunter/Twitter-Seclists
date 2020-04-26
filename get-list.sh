#!/bin/bash
LIST_ID=$1
LIST_NAME=$(curl -s https://twitter.com/i/lists/$LIST_ID | grep "<title>" | awk -F'/' '{ print $2 }' | awk '{print $1}')
CURSOR="-1"
DIR=$PWD/lists/$LIST_NAME-$LIST_ID
RAW="$DIR/raw"

mkdir -p $RAW
rm -rf $RAW/*

while true; do
  if [ $CURSOR -eq 0 ]; then
    break
  fi;
  curl -s -X GET -H "Authorization: Bearer $(cat $PWD/.env | head -n 1)" \
  "https://api.twitter.com/1.1/lists/members.json?list_id=$LIST_ID&cursor=$CURSOR&skip_status=true" \
  >> $RAW/$CURSOR
  CURSOR=$(cat $RAW/$CURSOR | jq '.next_cursor')
done

./process-list.sh $DIR
