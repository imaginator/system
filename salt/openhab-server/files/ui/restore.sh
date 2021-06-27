#!/bin/sh 
for individualPage in $(jq  -r '.[]| .uid' pages.json); do                                    
  echo $individualPage ;  
  jq '.[] | select(.uid=="'$individualPage'") | .'  pages.json   | \
  curl -X PUT  "http://openhab.imagilan/rest/ui/components/ui:page/$individualPage" \
    --user apiuser:apipassword \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    -d @-
done