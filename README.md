# Privilege Escalation - Sudo - CVE-2019-14287
This attack is based on the MITRE ATT&CK Privilege Escalation Tactic by using the [Sudo Technique](https://attack.mitre.org/techniques/T1169/). <br />
It makes use of the misconfiguration in the sudoers file, as described in CVE-2019-14287. 

# Description of the vulnerability

This vulnerability allows a non-root user to run commands as root. 
The sudo command can be run alternatively by passing user id instead of a username as an argument, along with the command. 
If an attacker passes -1 or 4294967295 as the user id, they can get the ability to run commands as root. 

For this exploit to work successfully, the /etc/sudoers file has to be misconfigured in a specific way. 
An example of said misconfiguration would be :- <br />
`<username> ALL=(ALL, !root) /bin/cat`

Essentially, the configuration above gives <username> the ability to execute /bin/cat on ALL hosts, but not as root.

This gets violated and results in root access when the user does something like :-<br /> `sudo -u#-1 /bin/cat`

For the sake of brevity, I would not get into the root cause of this issue here. 
## Exploit Action
The exploit works by checking various commands to see if they can be used to get root access. 
In cases where the attack is successful, the exploit points out the misconfigurations in the sudoers file. 
At the end, the exploit code generates a summary of the commands that are successful in obtaining root access.

In the case of this exploit, for demonstration purposes, the user saad is setup to have access to the bash command only. 
The exploit checks for `'/usr/bin/id', 'bash'` and `'/bin/cat'` commands.

# Preconditions to setup the attack
* **Base OS:** linux/macOS. (It can work on Windows too but hasn't been tested there)
* **Open Source Software:** 
    1. Docker version 19.03.4 
    2. docker-compose version 1.24.1
    3. git

# Preconditions to execute the attack
The docker container is built such that it satisfies all the preconditions for successful execution of the exploit.
The preconditions for successful execution of the attack are:
* **OS:** ubuntu:18.04
* **Programs:** git, python3.6, python3-pip, wget, gcc, make and sudo version 1.8.27 

# Step 1 - Setup
* Fire up the base OS and Docker. Once docker is up and running, clone this repository using `git clone` or manual download. 
* Open terminal in the directory where the files are located.
* Make sure that docker-compose.yml, Dockerfile, exploit.py and README.md are present before moving on to the next step.

# Step 2 - Execution
* Run the following commands in the order specified below:
1. `docker-compose build `
2. `docker-compose run sudoexploit`
## Attack Execution and Postconditons 
   * At this point, the exploit code would run and output the results to the tty.
   * If the exploit is successful, the summary line would say:- <br /><br />
     > The user can run the sudo exploit using these command(s)['bash']<br />
     > Exploit successful<br />
   * If no command has sudo access, the summary line would say:- <br /><br />
     > Exploit was not successful. No exploitable commands found.
    <br /><br />
   * If a user other than the one specified in the exploit code tries to run the exploit, the summary line would say:- <br />       <br />
     > Exploit cannot be run if user is not saad.
    <br /> <br />
   * Should an error occur, the summary line would say :-<br /> <br />
     > An error occured during the exploit execution<br /><br />
   * In addition to the above, the tty output is descriptive about the commands that work and don't work.

# Step 3 - Cleanup
* Run the following commands in the order specified below:
1. `docker-compose stop`
2. `docker-compose down`
3. `docker image rm secdev-test_sudoexploit`

* Delete the directory which contains all the files on the Base OS.
# Summary

I like how this exploit is quick and easy to setup by leveraging docker. The environment for the attack execution can be reliably set up and replicated. In addition to that, the ability to supply a list of commands to the exploit code and see the results quickly is very efficient. The code also points out the misconfigurations in the sudoers file, in case of a successful exploit. This can be very handy for fixing this issue as it points out clearly that what needs to be looked for. 

From the perspective of code - reasonable amount of error handling and edge case checking has been implemented. However, not every edge case is accounted for, since this is a POC. 


 
