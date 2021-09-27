# Creating a Drone server

You should look through the installation instructions on the drone
website; they are pretty good.

Then have a read through `make_drone.sh` which starts an ec2 server
and installs the drone docker containers on it. You will need to
change some of the values in this file including `ADMIN_USERNAME`
to be the **Github username** of someone you want to be an
administrator. You may also need to change the `DRONE_GITHUB_CLIENT_ID`
and `DRONE_GITHUB_CLIENT_SECRET` to be the correct values, if you
created a new Github OAuth app when following the drone install
instructions.

You also need to make this drone server work with the Pendulum
network setup. At the moment there is a load balancer set up for
drone.wholebiome.com so you need to add this newly created ec2
instance to the target group of the load balancer.
