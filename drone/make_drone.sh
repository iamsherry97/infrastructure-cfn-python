# The following set of commands can be used to set up done on a single server

# This will end up being the name of the ec2 instance running drone
export MACHINE_NAME=drone2

# balto can be installed from github.com/wholebiome/balto
balto launch --ec2type=t2.large $MACHINE_NAME

# This will activate the machine so that the
# following docker commands are run on the server
# rather than your local computer.
eval $(docker-machine env $MACHINE_NAME)

export DRONE_SERVER=drone.wholebiome.com

# The following two variables are created by generating
# a github OAuth app
export DRONE_GITHUB_CLIENT_ID=90bc40bfa5c10f54b232
export DRONE_GITHUB_CLIENT_SECRET=600199e4f9867e9f8709a861e837efaf05314d73

# This should be the github name of a user that you want to give admin rights to
# This user can make other users admin
export ADMIN_USERNAME=ctSkennerton

# This is a variable that the drone server and drone agents can use to talk with one another
export DRONE_RPC_SECRET=$(openssl rand -hex 16)  #d5793a7fb2616f755d7f9ceda7c0483e 

docker pull drone/drone:1

docker run \
  --volume=/var/lib/drone:/data \
  --env=DRONE_USER_CREATE=username:${ADMIN_USERNAME},admin:true \
  --env=DRONE_AGENTS_ENABLED=true \
  --env=DRONE_GITHUB_SERVER=https://github.com \
  --env=DRONE_GITHUB_CLIENT_ID=$DRONE_GITHUB_CLIENT_ID \
  --env=DRONE_GITHUB_CLIENT_SECRET=$DRONE_GITHUB_CLIENT_SECRET \
  --env=DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \
  --env=DRONE_SERVER_HOST=$DRONE_SERVER \
  --env=DRONE_SERVER_PROTO=https \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:1

docker pull drone/agent:1

docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DRONE_RPC_PROTO=https \
  -e DRONE_LOGS_TRACE=true \
  -e DRONE_RPC_HOST=$DRONE_SERVER \
  -e DRONE_RPC_SECRET= ${DRONE_RPC_SECRET} \
  -e DRONE_RUNNER_CAPACITY=2 \
  -p 3000:3000 \
  --restart always \
  --name runner \
  drone/agent:1
