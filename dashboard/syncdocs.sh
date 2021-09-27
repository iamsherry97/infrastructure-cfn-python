#!/bin/sh
export AWS_DEFAULT_REGION=us-west-2 


run_id=$(date +%Y%m%d%H%M)

/usr/bin/docker network prune --force
/usr/bin/docker network create -d bridge boxer_$run_id

/usr/bin/docker run --rm --env COLUMNS=120 --env LINES=40 -v /var/run/docker.sock:/var/run/docker.sock -v /home/ubuntu/.boxer:/environment/ -v /home/ubuntu/.aws:/root/.aws -v /tmp/boxer_runs:/tmp/boxer_runs/ -v /tmp:/localdir/ --expose 8082 --expose 4444 -p 8082:8082 --network=boxer_$run_id --network-alias=inventory_D47CBC58 -e BOXER_LOCAL_RUNNING=1 -e BOXER_RUN_ID=$run_id -e BOXER_CONFIG_DIR=/home/ubuntu/.boxer -e BOXER_SCRATCH_DIR=/tmp/boxer_runs -e BOXER_INPUT_DIR=/tmp -e BOXER_SCHEDULER_HOST=localhost -e BOXER_WORKFLOW_NETWORK=boxer_$run_id -e BOXER_SCHEDULER_PORT=8082 -e BOXER_S3_PATH=s3://wb-boxer boxer/inventory:30d077501688 bash -c "./container.py --akserver https://akita.wholebiome.com --aktoken be9a2a4978725589534ef27191e49964b8952bbd"

sudo rm -fr /tmp/boxer_runs/$run_id

/home/ubuntu/.local/bin/aws s3 cp --recursive s3://wbkb/dashboard/ /var/www/ 
python3 /home/ubuntu/make_index.py
