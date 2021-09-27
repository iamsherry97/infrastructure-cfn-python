# Docs Server

This is the config for the "docs.wholebiome.com" server.

## Launching

Launched with balto:

```bash
balto launch --spot docs
eval $(docker-machine env docs)

# find IP with:
balto listmachines docs

# Update cname record for docs.wholebiome.com
export MACHINEDOMAIN="docs.wholebiome.com"
export MACHINEIP="52.88.11.172"
export HOSTEDZONE="Z1L31BET9POS2B"
echo "{\"Changes\":[{\"Action\": \"UPSERT\",\"ResourceRecordSet\":{\"Name\": \"$MACHINEDOMAIN\",\"Type\": \"A\",\"TTL\": 300,\"ResourceRecords\":[{\"Value\":\"$MACHINEIP\"}]}}]}" > change.json
aws route53 change-resource-record-sets --hosted-zone-id=$HOSTEDZONE --change-batch file://change.json

# Make web serve folder:
docker-machine ssh docs "sudo mkdir -p /var/www && sudo chown ubuntu:ubuntu /var/www"
docker-machine ssh docs "sudo mkdir -p /var/nginx/conf && sudo chown ubuntu:ubuntu /var/nginx/conf"
docker-machine ssh docs "echo \"docs\" > /var/www/index.html"


# Run nginx server:
docker run --name nginxdocs -v /var/www:/usr/share/nginx/html:ro -v /var/nginx/conf:/etc/nginx/conf:ro -p 80:80 -d nginx
```

# Set up document syncing with cron

```bash
docker-machine scp syncdocs.sh ubuntu@docs:~/syncdocs.sh
docker-machine ssh docs "(crontab -l ; echo '*/5 * * * * /home/ubuntu/syncdocs.sh') | crontab -"
```

Now any documentation that is added to the s3 path will be synced to the server every 5 minutes

Usage example:

```
docker-machine scp ./site/ ubuntu@docs:/var/www/balto/ --recursive
```
which becomes http://docs.wholebiome.com/balto
