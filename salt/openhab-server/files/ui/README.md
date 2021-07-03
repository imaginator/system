## 

Backup:
curl -X GET "http://openhab.imagilan/rest/ui/components/ui:page" | jq '.| sort_by(.uid)' > /srv/salt_local/salt/openhab-server/files/ui/page/pages.json
curl -X GET "http://openhab.imagilan/rest/ui/components/ui:widget" | jq '.| sort_by(.uid)' > /srv/salt_local/salt/openhab-server/files/ui/widget/widgets.json 
