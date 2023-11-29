# SixFifty Production Monitoring

Minimalist monitoring with PagerDuty. It is deployed in AWS to the us-west-2 region to a [t2.nano ec2 instance](https://us-west-2.console.aws.amazon.com/ec2/home?region=us-west-2#InstanceDetails:instanceId=i-0465b7669adb04f55). The key to access the EC2 is stored in Bitwarden under "Monitoring SSH Key". It's in us-west-2 because it's far away from us-east-1 and problems in us-east-1 generally don't occur at the same time in us-west-2.

> Note: Be sure to `chmod 400` the ssh key after copying it locally or you won't be able to connect.

This service requests the urls listed in services.json and on error, posts a message using pager duty details which will post to the slack channel #engineering-alerts.


## Configuration
Secrets are stored in us-west-2 Secrets Manager in AWS. Use `get-env.sh` to create services.json. There are not multiple environments. It's just 'prod'.

-------------

## Build
Requires working [Go environment](https://golang.org).

`go build`

-------------

## Execution
Running locally is as easy as running the built executable:
`./monitor`

-------------

## Deployment

Add this to your ~/.ssh/config
```
Host monitoring
	HostName 35.90.6.245
	User ec2-user
	IdentityFile ~/.ssh/monitoring-west-2.pem
```
The deploy.sh script does all the work including configuring the systemd service.

To verify deployment, ssh to the box and run 
`ps aux | grep monitor`

Output should look something like this:
```
root       34764  0.6  2.5 1020728 11780 ?       Ssl  16:29   0:00 /home/ec2-user/monitor/monitor
ec2-user   34811  0.0  0.4 222312  2016 pts/1    S+   16:29   0:00 grep --color=auto monitor
```

Script should be running as root from `/home/ec2-user/monitor`

## Testing
Edit /etc/hosts and redirect one of the urls in services.json to 127.0.0.1. Restart the monitoring service. A message should appear in #engineering-alerts within  a minute or so. Remove the line in /etc/hosts and restart the service to go back to normal.


-------------

## systemd
We use `systemd` to run the service on the monitoring service. Most linux distributions need this file in `/etc/systemd/system`. Once there, use these commands to manage it:
* `sudo systemctl daemon-reload` 
    Reloads the systemd daemon. Necessary after initally installation of the monitor.service script
* `sudo systemctl enable monitor.service`
    Enables the service to be started on startup (does not start the service). If the service is not enabled, system3 will not auto-start the service on reboot.
* `sudo systemctl start monitor.service`
    Starts the service immediately.

I found [this](https://timleland.com/how-to-run-a-linux-program-on-startup/) webpage helpful.
