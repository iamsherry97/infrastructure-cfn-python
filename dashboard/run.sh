export MACHINEDOMAIN="dashboard.wholebiome.com"
export MACHINEIP="52.33.96.8"
export HOSTEDZONE="Z1L31BET9POS2B"
echo "{\"Changes\":[{\"Action\": \"UPSERT\",\"ResourceRecordSet\":{\"Name\": \"$MACHINEDOMAIN\",\"Type\": \"A\",\"TTL\": 300,\"ResourceRecords\":[{\"Value\":\"$MACHINEIP\"}]}}]}" > change.json
aws route53 change-resource-record-sets --hosted-zone-id=$HOSTEDZONE --change-batch file://change.json

# Make web serve folder:
docker-machine ssh dashboard "sudo mkdir -p /var/www && sudo chown ubuntu:ubuntu /var/www"
docker-machine ssh dashboard "sudo mkdir -p /var/nginx/conf && sudo chown ubuntu:ubuntu /var/nginx/conf"
docker-machine ssh dashboard "echo \"dashboard\" > /var/www/index.html"


# Run nginx server:
#docker run --name nginxdashboard -v /var/www:/usr/share/nginx/html:ro -v /var/nginx/conf:/etc/nginx/conf:ro -p 80:80 -d nginx

