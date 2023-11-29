# SixFifty Production Monitoring

Minimalist monitoring with PagerDuty. It is deployed in AWS to the us-west-2 region to a t2.nano ec2 instance. The key to access it is stored in Bitwarden under "Monitoring SSH Key". It's in us-west-2 because it's far away from us-east-1 and problems in us-east-1 generally don't occur at the same time in us-west-2.

This service requests the urls listed in services.json and on error, posts a message using pager duty details whichw ill post to the slack channel #engineering-alerts.


## Configuration
Secrets are stored in us-west-2 Secrets Manager in AWS. Use `get-env.sh` to create `services.json`. There are not multiple environments. It's just 'prod'.

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
There's a deploy.sh script that does all the work. The only thing it doesn't do is install the  `systemd` service. If the service is configured, the deploy script will stop the service, deploy the files, and restart the service.

To verify deployment, ssh to the box and run 
`ps aux | grep monitor`

Output should look something like this:
```
root       34764  0.6  2.5 1020728 11780 ?       Ssl  16:29   0:00 /home/ec2-user/monitor/monitor
ec2-user   34811  0.0  0.4 222312  2016 pts/1    S+   16:29   0:00 grep --color=auto monitor
```

Script should be running as root from `/home/ec2-user/monitor`


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
