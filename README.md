## microcontainer based on Alpine with working init process

[![](https://badge.imagelayers.io/nimmis/alpine:latest.svg)](https://imagelayers.io/?images=nimmis/alpine:latest)

This is a very small container (51 Mb) but still have a working init process, crond and syslog. This is the base image for all my other microcontainers

### Why use this image

The unix process ID 1 is the process to receive the SIGTERM signal when you execute a 

	docker stop <container ID>

if the container has the command `CMD ["bash"]` then bash process will get the SIGTERM signal and terminate.
All other processes running on the system will just stop without the possibility to shutdown correclty

### my_init init script

In this container i have a scipt that handles the init process an uses the [supervisor system](http://supervisord.org/index.html) to start
the daemons to run and also catch signals (SIGTERM) to shutdown all processes started by supervisord. This is a modified version of
an init script made by Phusion. I've modified it to use supervisor in stead of runit. There are also two directories to run scripts
before any daemon is started.

#### Run script once /etc/my_runonce

All executable in this directory is run at start, after completion the script is removed from the directory

#### Run script every start /etc/my_runalways

All executable in this directory is run at every start of the container, ie, at `docker run` and `docker start`

#### Permanent output to docker log when starting container

Each time the container is started the content of the file /tmp/startup.log is displayed so if your startup scripts generate 
vital information to be shown please add that information to that file. This information can be retrieved anytime by
executing `docker logs <container id>`

### cron daemon

In many cases there are som need of things happening att given intervalls, default no cron processs is started
in standard images. In this image cron is running together with logrotate to stop the logdfiles to be
to big on log running containers.

### rsyslogd

No all services works without a syslog daemon, if you don't have one running those messages is lost in space,
all messages sent via the syslog daemon is saved in /var/log/syslog

### Docker fixes 

Also there are fixed (besideds the init process) assosiated with running linux inside a docker container.

### New commands autostarted by supervisord

To add other processes to run automaticly, add a file ending with .conf  in /etc/supervisor.d/ 
with a layout like this (/etc/supervisor.d/myprogram.conf) 

	[program:myprogram]
	command=/usr/bin/myprogram

`myprogram` is the name of this process when working with supervisctl.

Output logs std and error is found in /var/log/supervisor/ and the files begins with the <defined name><-stdout|-stderr>superervisor*.log

For more settings please consult the [manual FOR supervisor](http://supervisord.org/configuration.html#program-x-section-settings)

#### starting commands from /etc/init.d/ or commands that detach with my_service

The supervisor process assumes that a command that ends has stopped so if the command detach it will try to restart it. To work around this
problem I have written an extra command to be used for these commands. First you have to make a normal start/stop command and place it in
the /etc/init.d that starts the program with

	/etc/init.d/command start or
	service command start

and stops with

        /etc/init.d/command stop or
        service command stop

Configure the configure-file (/etc/supervisor.d/myprogram.conf)

	[program:myprogram]
	command=/my_service myprogram

There is an optional parameter, to run a script after a service has start, e.g to run the script /usr/local/bin/postproc.sh av myprogram is started

        [program:myprogram]
        command=/my_service myprogram /usr/local/bin/postproc.sh

### Output information to docker logs

The console output is owned by the my_init process so any output from commands woun't show in the docker log. To send a text from any command, either
at startup och during run, append the output to the file /var/log/startup.log, e.g sending specific text to log

	echo "Application is finished" >> /var/log/startup.log

or output from script

	/usr/local/bin/myscript >> /var/log/startlog.log


	> docker run -d --name alpine nimmis/alpine
	> docker logs microbase
	*** open logfile
	*** Run files in /etc/my_runonce/
	*** Run files in /etc/my_runalways/
	*** Booting supervisor daemon...
	*** Supervisor started as PID 6
	2015-08-04 11:34:06,763 CRIT Set uid to user 0
	*** Started processes via Supervisor......
	crond                            RUNNING    pid 9, uptime 0:00:04
	rsyslogd                         RUNNING    pid 10, uptime 0:00:04

	> docker exec alpine sh -c 'echo "Testmessage to log" >> /var/log/startup.log'
	> docker logs alpine
        *** open logfile
        *** Run files in /etc/my_runonce/
        *** Run files in /etc/my_runalways/
        *** Booting supervisor daemon...
        *** Supervisor started as PID 6
        2015-08-04 11:34:06,763 CRIT Set uid to user 0
        *** Started processes via Supervisor......
        crond                            RUNNING    pid 9, uptime 0:00:04
        rsyslogd                         RUNNING    pid 10, uptime 0:00:04

	*** Log: Testmessage to log
        >

### Installation

This continer should normaly run as a daemon i.e with the `-d` flag attached

	docker run -d nimmis/alpine

but if you want to check if all services has been started correctly you can start with the following command

	docker run -ti nimmis/alpine

the output, if working correctly should be

	docker run -ti nimmis/alpine
	*** open logfile
	*** Run files in /etc/my_runonce/
	*** Run files in /etc/my_runalways/
	*** Booting supervisor daemon...
	*** Supervisor started as PID 7
	2015-01-02 10:45:43,750 CRIT Set uid to user 0
	crond[10]: crond (busybox 1.24.1) started, log level 8
	*** Started processes via Supervisor......
	crond                            RUNNING    pid 10, uptime 0:00:04
	rsyslogd                         RUNNING    pid 11, uptime 0:00:04

pressing a CTRL-C in that window  or running `docker stop <container ID>` will generate the following output

	*** Shutting down supervisor daemon (PID 7)...
	*** Killing all processes...

you can the restart that container with 

	docker start <container ID>

Accessing the container with a shell can be done with

	docker exec -ti <container ID> /bin/sh

### TAGs

This image only contains the latest versions of Apline, the versions are
nimmis/alpine:<tag> where tag is

| Tag    | Alpine version | size |
| ------ | -------------- | ---- |
| latest |  latest/3.8    | [![](https://images.microbadger.com/badges/image/nimmis/alpine.svg)](https://microbadger.com/images/nimmis/alpine "Get your own image badge on microbadger.com") |
| test |  latest/edge    | [![](https://images.microbadger.com/badges/image/nimmis/alpine:test.svg)](https://microbadger.com/images/nimmis/alpine:test "Get your own image badge on microbadger.com") |
| 3.9    |  3.9           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.9.svg)](https://microbadger.com/images/nimmis/alpine:3.9 "Get your own image badge on microbadger.com") |
| 3.8    |  3.8           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.8.svg)](https://microbadger.com/images/nimmis/alpine:3.8 "Get your own image badge on microbadger.com") |
| 3.7    |  3.7           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.7.svg)](https://microbadger.com/images/nimmis/alpine:3.7 "Get your own image badge on microbadger.com") |
| 3.6    |  3.6           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.6.svg)](https://microbadger.com/images/nimmis/alpine:3.6 "Get your own image badge on microbadger.com") |
| 3.5    |  3.5           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.5.svg)](https://microbadger.com/images/nimmis/alpine:3.5 "Get your own image badge on microbadger.com") |
| 3.4    |  3.4           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.4.svg)](https://microbadger.com/images/nimmis/alpine:3.4 "Get your own image badge on microbadger.com") |
| 3.3    |  3.3           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.3.svg)](https://microbadger.com/images/nimmis/alpine:3.3 "Get your own image badge on microbadger.com") |
| 3.2    |  3.2           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.2.svg)](https://microbadger.com/images/nimmis/alpine:3.2 "Get your own image badge on microbadger.com") |
| 3.1    |  3.1           | [![](https://images.microbadger.com/badges/image/nimmis/alpine:3.1.svg)](https://microbadger.com/images/nimmis/alpine:3.1 "Get your own image badge on microbadger.com") |
| edge   |  edge          | [![](https://images.microbadger.com/badges/image/nimmis/alpine:edge.svg)](https://microbadger.com/images/nimmis/alpine:edge "Get your own image badge on microbadger.com") |
