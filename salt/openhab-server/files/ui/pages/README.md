## 

Backup:
`curl -X GET "http://openhab.imagilan/rest/ui/components/ui:page"   > /srv/salt_local/salt/openhab-server/files/ui/page/pages.json`
`curl -X GET "http://openhab.imagilan/rest/ui/components/ui:widget" > /srv/salt_local/salt/openhab-server/files/ui/widget/widgets.json`

Install:

```
curl -X  POST "http://openhab.imagilan/rest/ui/components/ui:page"  \
    --user simon  \
    -H  "accept: application/json" \
    -H  "Content-Type: */*"  \
    -d @/srv/salt_local/salt/openhab-server/files/ui/page/pages.json
```